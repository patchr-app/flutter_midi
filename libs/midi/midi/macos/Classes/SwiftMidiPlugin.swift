import FlutterMacOS
import CoreMIDI

public class SwiftMidiPlugin: NSObject, FlutterPlugin {

  var methodChannel: FlutterMethodChannel;
  var deviceEventChannel: FlutterEventChannel;
  var midiDataChannel: FlutterEventChannel;
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: Constants.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger)
    let deviceEventChannel = FlutterEventChannel(name: Constants.DEVICE_CHANNEL_NAME, binaryMessenger: registrar.messenger)
    let messageEventChannel = FlutterEventChannel(name: Constants.MESSAGE_CHANNEL_NAME, binaryMessenger: registrar.messenger)
    let instance = SwiftMidiPlugin(methodChannel: methodChannel, deviceEventChannel: deviceEventChannel, midiDataChannel: messageEventChannel)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }


  init(methodChannel: FlutterMethodChannel, deviceEventChannel: FlutterEventChannel, midiDataChannel: FlutterEventChannel) {
    self.methodChannel = methodChannel;
    self.deviceEventChannel = deviceEventChannel;
    self.midiDataChannel = midiDataChannel;
    super.init();
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
    
    for (id, port) in midiAccess.outputs {
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
    
    for (id, port) in midiAccess.inputs {
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
    result(Void());
  }
  func openSource(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }

  func closeDestination(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  func closeSource(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  func send(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  
  func buildId(port: MIDIPort) -> String {
    return String(port.id);
  }
  func getPortId(id: String) -> Int {
    return Int(id) ?? 0
  }
  
}
