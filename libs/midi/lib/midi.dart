import 'dart:async';

import 'package:flutter/services.dart';

/// Method channel used for all midi related stuff
const MethodChannel _channel = const MethodChannel('com.synthfeeder/midi');
const EventChannel _deviceEventchannel =
    const EventChannel('com.synthfeeder/midi/devices');

enum PortType { input, output }

/// Information about a port contained in a device
class PortInfo {
  String name;
  int number;
  PortType type;

  PortInfo(Map props) {
    props.forEach((key, val) => print('$key : $val'));
    this.name = props['name'];
    this.number = props['number'];
    this.type = props['type'] == 'INPUT' ? PortType.input : PortType.output;
  }

  toJson() {
    return {'name': name, 'number': number, 'type': type};
  }
}

/// Information about a single midi device on the system
class DeviceInfo {
  int id;
  int inputPortCount;
  int outputPortCount;
  String type;
  String manufacturer;
  String name;
  String product;
  String serialNumber;
  String version;
  List<PortInfo> ports;

  DeviceInfo(Map props) {
    this.id = props['id'];
    this.inputPortCount = props['inputPortCount'];
    this.outputPortCount = props['outputPortCount'];
    this.type = props['type'];
    this.manufacturer = props['manufacturer'];
    this.name = props['name'];
    this.product = props['product'];
    this.serialNumber = props['serialNumber'];
    this.version = props['version'];
    this.ports = (props['ports'] as List).map((p) => new PortInfo(p)).toList();
  }

  toJson() {
    return {
      'id': id,
      'inputPortCount': inputPortCount,
      'outputPortCount': outputPortCount,
      'type': type,
      'manufacturer': manufacturer,
      'name': name,
      'product': product,
      'serialNumber': serialNumber,
      'version': version,
      'ports': ports,
    };
  }
}

class MidiOutputPort {
  int getPortNumber() {
    return 0;
  }
}

class MidiDevice {
  int _id;
  bool _open;

  MidiDevice(this._id) {
    this._open = true;
  }

  openInputPort(int port) {}
  MidiOutputPort openOutputPort(int port) {
    return null;
  }

  close() async {
    await _channel.invokeMethod('closeDevice', this._id);
    this._open = false;
  }
}

enum MidiDeviceChangeType { Added, Removed }

class MidiDeviceChange {
  MidiDeviceChangeType type;
  DeviceInfo device;

  MidiDeviceChange(Map props) {
    type = props['type'] == 'DEVICE_ADDED'
        ? MidiDeviceChangeType.Added
        : MidiDeviceChangeType.Removed;
    device = new DeviceInfo(props['device']);
  }
}

class Midi {
  /// Gets the list of midi devices present on the system
  Future<List<DeviceInfo>> listDevices() async {
    var result = await _channel.invokeMethod('listDevices') as List;
    return result.map((res) {
      return new DeviceInfo(res);
    }).toList();
  }

  Stream<MidiDeviceChange> get onDevicesChanged {
    return _deviceEventchannel
        .receiveBroadcastStream()
        .map((dynamic event) => new MidiDeviceChange(event));
  }

  Future<MidiDevice> openDevice(DeviceInfo d) async {
    var result = await _channel.invokeMethod('openDevice', d.id);
    return MidiDevice(result);
  }
}
