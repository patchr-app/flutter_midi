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
    
    if (call.method==(Constants.GET_INPUTS)) {
      self.getInputs(call: call, result: result);
    } else if (call.method==(Constants.GET_OUTPUTS)) {
      self.getOutputs(call: call, result: result);
    } else if (call.method==(Constants.OPEN_INPUT)) {
      self.openInput(call: call, result: result);
    } else if (call.method==(Constants.OPEN_OUTPUT)) {
      self.openOutput(call: call, result: result);
    } else if (call.method==(Constants.CLOSE_INPUT)) {
      self.closeInput(call: call, result: result);
    } else if (call.method==(Constants.CLOSE_OUTPUT)) {
      self.closeOutput(call: call, result: result);
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
  func getInputs(call: FlutterMethodCall, result: FlutterResult) {
    var ports: Array<Dictionary<String, Any>> = [];
    let count: Int = MIDIGetNumberOfDestinations();
    for i in 0 ..< count {
      var properties: Dictionary<String, Any> = [:]
      var param: Unmanaged<CFString>?
      let endpoint:MIDIEndpointRef = MIDIGetDestination(i);
      properties[Constants.NUMBER] = i;
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyManufacturer, &param)
      properties[Constants.MANUFACTURER] = param!.takeRetainedValue() as String
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &param)
      properties[Constants.NAME] = param!.takeRetainedValue() as String
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDriverVersion, &param)
      properties[Constants.VERSION] = param!.takeRetainedValue() as String
      
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyUniqueID, &param)
      properties[Constants.ID] = param!.takeRetainedValue() as String
      ports.append(properties);
    }
    result(ports);
  }

  func getOutputs(call: FlutterMethodCall, result: FlutterResult) {
    var ports: Array<Dictionary<String, Any>> = [];
    let count: Int = MIDIGetNumberOfSources();
    for i in 0 ..< count {
      var properties: Dictionary<String, Any> = [:]
      var param: Unmanaged<CFString>?
      let endpoint:MIDIEndpointRef = MIDIGetSource(i);
      properties[Constants.NUMBER] = i;
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyManufacturer, &param)
      properties[Constants.MANUFACTURER] = param!.takeRetainedValue() as String
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &param)
      properties[Constants.NAME] = param!.takeRetainedValue() as String
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDriverVersion, &param)
      properties[Constants.VERSION] = param!.takeRetainedValue() as String
      
      MIDIObjectGetStringProperty(endpoint, kMIDIPropertyUniqueID, &param)
      properties[Constants.ID] = param!.takeRetainedValue() as String
      ports.append(properties);
    }
    result(ports);
  }

  func openInput(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  func openOutput(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }

  func closeInput(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  func closeOutput(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
  func send(call: FlutterMethodCall, result: FlutterResult) {
    result(Void());
  }
}
