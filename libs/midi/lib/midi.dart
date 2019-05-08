library midi;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

part './src/device.dart';
part './src/device_change_event.dart';
part './src/device_info.dart';
part './src/input_port.dart';
part './src/output_port.dart';
part './src/port_info.dart';
part './src/message_filters.dart';
part './src/message_splitter.dart';
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

  /**
   * A stream that emits the current list of devices, whenever
   * something changes
   */
  Stream<List<DeviceInfo>> devices() async* {
    List<DeviceInfo> state = await this.listDevices();
    yield state;
    await for (MidiDeviceChangeEvent event in this.onDevicesChanged) {
      if (event.type == MidiDeviceChangeType.Added) {
        state.add(event.device);
      } else {
        state.removeWhere((item) => item.id == event.device.id);
      }
      yield state;
    }
  }

  Stream<List<PortInfo>> inputs() async* {
    await for (List<DeviceInfo> devices in this.devices()) {
      List<PortInfo> inputs = [];
      for (DeviceInfo device in devices) {
        for (PortInfo port in device.ports) {
          if (port.type == PortType.input) {
            inputs.add(port);
          }
        }
      }
      yield inputs;
    }
  }

  Stream<List<PortInfo>> outputs() async* {
    await for (List<DeviceInfo> devices in this.devices()) {
      List<PortInfo> outputs = [];
      for (DeviceInfo device in devices) {
        for (PortInfo port in device.ports) {
          if (port.type == PortType.output) {
            outputs.add(port);
          }
        }
      }
      yield outputs;
    }
  }

  Future<MidiInputPort> openInput(PortInfo p) async {
    MidiDevice d = await this.openDevice(p.parent);
    return await d.openInputPort(p);
  }

  Future<MidiOutputPort> openOutput(PortInfo p) async {
    MidiDevice d = await this.openDevice(p.parent);
    return await d.openOutputPort(p);
  }

  Future<MidiDevice> openDevice(DeviceInfo d) async {
    var result = await _channel.invokeMethod('openDevice', d.id);
    return MidiDevice(result);
  }
}
