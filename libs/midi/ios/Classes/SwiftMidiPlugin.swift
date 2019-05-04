import Flutter
import UIKit
import CoreMIDI


public class SwiftMidiPlugin: NSObject, FlutterPlugin {
  let channel: FlutterMethodChannel;
  let deviceEventChannel: FlutterEventChannel;
  let midiMessageChannel: FlutterEventChannel;
  
  init(channel: FlutterMethodChannel, deviceEventChannel: FlutterEventChannel, midiMessageChannel: FlutterEventChannel) {
    self.channel = channel
    self.deviceEventChannel = deviceEventChannel
    self.midiMessageChannel = midiMessageChannel
  }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.synthfeeder/midi", binaryMessenger: registrar.messenger())
    let deviceEventChannel = FlutterEventChannel(name: "com.synthfeeder/midi/devices", binaryMessenger: registrar.messenger())
    let midiMessageChannel = FlutterEventChannel(name: "com.synthfeeder/midi/messages", binaryMessenger: registrar.messenger())
    
    let instance = SwiftMidiPlugin(channel: channel, deviceEventChannel: deviceEventChannel, midiMessageChannel: midiMessageChannel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "listDevices") {
      result(self.getDevices())
    }
  }
  
  public func getDevices() -> Array<Dictionary<String, Any>> {
    print("GETTING DEVICES");
    var devices: Array<Dictionary<String, Any>> = []
    let deviceCount = MIDIGetNumberOfDevices();
    print("Device Count:");
    print(deviceCount);
    for i in 0 ..< deviceCount {
      let device = MIDIGetDevice(i)

      var isOffline: Int32 = 0
      MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &isOffline)
      if isOffline > 0 {
        print("Device is online")
        var props: Dictionary<String, Any> = [:]
        
        let itemCount = MIDIDeviceGetNumberOfEntities(device);
        print("Entity Count:")
        print (itemCount)
        
        for entityId in 0 ..< itemCount {
          let entity = MIDIDeviceGetEntity(device, entityId)
          
          let sourceCount = MIDIEntityGetNumberOfSources(entity);
          /// XXX TODO ETC
        }
        
        props["id"] = i
        props["name"] = getStringProp(object: device, prop: kMIDIPropertyName)
        props["manufacturer"] = getStringProp(object: device, prop: kMIDIPropertyManufacturer)
        props["product"] = getStringProp(object: device, prop: kMIDIPropertyModel)
        props["serialNumber"] = getStringProp(object: device, prop: kMIDIPropertyDriverVersion)
        devices.append(props)
      }
      else {
        print("Device offline")
      }
    }

    return devices;
  }
  
  public func getStringProp(object: MIDIDeviceRef, prop: CFString) -> String {
    var param: Unmanaged<CFString>?
    var name: String = "ERROR"
    if noErr == MIDIObjectGetStringProperty(object, prop, &param) {
      name = param!.takeRetainedValue() as String
    }
    return name;
  }
}
