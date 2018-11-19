library midi;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

part './src/device.dart';
part './src/device_change_event.dart';
part './src/device_info.dart';
part './src/output_port.dart';
part './src/port_info.dart';
part './src/message_types.dart';

/// Method channel used for all midi related stuff
const MethodChannel _channel = const MethodChannel('com.synthfeeder/midi');
const EventChannel _deviceEventchannel =
    const EventChannel('com.synthfeeder/midi/devices');
const EventChannel _midiMessagechannel =
    const EventChannel('com.synthfeeder/midi/messages');

class Midi {
  /// Gets the list of midi devices present on the system
  Future<List<DeviceInfo>> listDevices() async {
    var result = await _channel.invokeMethod('listDevices') as List;
    return result.map((res) {
      return new DeviceInfo(res);
    }).toList();
  }

  Stream<MidiDeviceChangeEvent> get onDevicesChanged {
    return _deviceEventchannel
        .receiveBroadcastStream()
        .map((dynamic event) => new MidiDeviceChangeEvent(event));
  }

  Future<MidiDevice> openDevice(DeviceInfo d) async {
    var result = await _channel.invokeMethod('openDevice', d.id);
    return MidiDevice(result);
  }
}
