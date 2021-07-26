import Flutter
import UIKit
import CoreMIDI


public class MidiEventPublisher: FlutterStreamHandler {
  var sendMidiData: Bool = false
  var midiDataSink: FlutterEventSink?
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    midiDataSink = events;
    sendMidiData = true;
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sendMidiData = false;
    return nil
  }
  
  public func send(deviceId: String, data: Data) {
    guard let eventSink = midiDataSink else {
      return
    }
    if (sendMidiData) {
      var message: Dictionary<String, Any> = [:];
      message[Constants.PORT] = deviceId
      message[Constants.DATA] = data
      eventSink(message)
    }
    else {
      print("not sending")
    }
  }
}


public class DeviceEventPublisher: FlutterStreamHandler {
  var sendEvents: Bool = false
  var eventSink: FlutterEventSink?
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events;
    sendEvents = true;
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sendEvents = false;
    return nil
  }
  
  public func onChange(port: MIDIPort) {
    guard let eventSink = eventSink else {
      return
    }
    if (!sendEvents) {
      return
    }
    
    let info: Dictionary<String, Any> = [
      Constants.ID: buildId(port : port),
      Constants.STATE: port.state == .connected ? Constants.CONNECTED : Constants.DISCONNECTED,
      Constants.PORT: [
        Constants.NUMBER: port.id,
        Constants.ID: buildId(port : port),
        Constants.MANUFACTURER: port.manufacturer,
        Constants.NAME: port.displayName,
        Constants.TYPE: port.type == .input ? Constants.SOURCE : Constants.DESTINATION
      ]
    ]
    eventSink(info)
  }
  func buildId(port: MIDIPort) -> String {
    return String(port.id);
  }

}




public class SwiftMidiIoPlugin: NSObject, FlutterPlugin {
  var methodChannel: FlutterMethodChannel;
  var deviceEventChannel: FlutterEventChannel;
  var midiDataChannel: FlutterEventChannel;
  
  var midiAccess: MIDIAccess;
  
  var sendMidiData: Bool = false;
  var messagePublisher: MidiEventPublisher = MidiEventPublisher();
  var devicePublisher: DeviceEventPublisher = DeviceEventPublisher();
  
  
  init(methodChannel: FlutterMethodChannel, deviceEventChannel: FlutterEventChannel, midiDataChannel: FlutterEventChannel) {
    self.methodChannel = methodChannel;
    self.deviceEventChannel = deviceEventChannel;
    self.midiDataChannel = midiDataChannel;
    midiDataChannel.setStreamHandler(messagePublisher as? FlutterStreamHandler & NSObjectProtocol)
    deviceEventChannel.setStreamHandler(devicePublisher as? FlutterStreamHandler & NSObjectProtocol)
    self.midiAccess = MIDIAccess()
    

    super.init()
    self.midiAccess.onStateChange = { (port: MIDIPort) in
      self.devicePublisher.onChange(port: port)
    }
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: Constants.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let deviceEventChannel = FlutterEventChannel(name: Constants.DEVICE_CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let messageEventChannel = FlutterEventChannel(name: Constants.MESSAGE_CHANNEL_NAME, binaryMessenger: registrar.messenger())

    let instance = SwiftMidiIoPlugin(methodChannel: methodChannel, deviceEventChannel: deviceEventChannel, midiDataChannel: messageEventChannel)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }


  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if (call.method==(Constants.GET_DESTINATIONS)) {
      self.getDestinations(call: call, result: result);
    } else if (call.method==(Constants.GET_SOURCES)) {
      self.getSources(call: call, result: result);
    } else if (call.method==(Constants.OPEN_DESTINATION)) {
      self.openDestination(call: call, result: result);
    } else if (call.method==(Constants.OPEN_SOURCE)) {
      self.openSource(call: call, result: result);
    } else if (call.method==(Constants.CLOSE_DESTINATION)) {
      self.closeDestination(call: call, result: result);
    } else if (call.method==(Constants.CLOSE_SOURCE)) {
      self.closeSource(call: call, result: result);
    } else if (call.method==(Constants.SEND)) {
      self.send(call: call, result: result);
    }
  }
  
  // final String id;
  // final String manufacturer;
  // final String name;
  // final MidiPortType type;
  // final String version;
  // final int number;
  func getDestinations(call: FlutterMethodCall, result: FlutterResult) {
    var ports: Array<Dictionary<String, Any>> = [];
    
    for (_, port) in midiAccess.outputs {
      var properties: Dictionary<String, Any> = [:]
      properties[Constants.NUMBER] = port.id;
      properties[Constants.ID] = buildId(port : port);
      properties[Constants.MANUFACTURER] = port.manufacturer;
      properties[Constants.NAME] = port.displayName;
      //properties[Constants.VERSION] = port.version;
      ports.append(properties)
    }
    result(ports);
  }

  func getSources(call: FlutterMethodCall, result: FlutterResult) {
    var ports: Array<Dictionary<String, Any>> = [];
    
    for (_, port) in midiAccess.inputs {
      var properties: Dictionary<String, Any> = [:]
      properties[Constants.NUMBER] = port.id;
      properties[Constants.ID] = buildId(port: port);
      properties[Constants.MANUFACTURER] = port.manufacturer;
      properties[Constants.NAME] = port.displayName;
      //properties[Constants.VERSION] = port.version;
      ports.append(properties)
    }
    result(ports);
  }

  func openDestination(call: FlutterMethodCall, result: FlutterResult) {
    let id = getPortId(id: call.arguments as! String);
    let port: MIDIOutput?  = midiAccess.outputs[id]
    port?.open();
  }
  func openSource(call: FlutterMethodCall, result: FlutterResult) {
    let id = getPortId(id: call.arguments as! String);
    let port: MIDIInput?  = midiAccess.inputs[id]
    port?.open();
    port?.onMIDIMessage = { (packet: MIDIEvent) in
      self.messagePublisher.send(deviceId: call.arguments as! String, data: packet.data)
    };
    result(call.arguments as! String);
  }

  func closeDestination(call: FlutterMethodCall, result: FlutterResult) {
    let id = getPortId(id: call.arguments as! String)
    let port: MIDIOutput?  = midiAccess.outputs[id]
    port?.close()
    result(call.arguments as! String);
  }
  
  func closeSource(call: FlutterMethodCall, result: FlutterResult) {
    let id = getPortId(id: call.arguments as! String)
    let port: MIDIInput?  = midiAccess.inputs[id]
    port?.close()
    result(call.arguments as! String);
  }
  
  func send(call: FlutterMethodCall, result: FlutterResult) {
    let args: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>;
    let id = getPortId(id: args[Constants.PORT] as! String)
    let data = args[Constants.DATA] as! FlutterStandardTypedData;
    let port: MIDIOutput?  = midiAccess.outputs[id]
    port?.send(data.data)
  }
  
  func buildId(port: MIDIPort) -> String {
    return String(port.id);
  }
  func getPortId(id: String) -> Int {
    return Int(id) ?? 0
  }
}
