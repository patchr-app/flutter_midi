import 'dart:async';

import 'package:flutter/services.dart';

/// Method channel used for all midi related stuff
const MethodChannel _channel = const MethodChannel('com.synthfeeder/midi');

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
}

class MidiOutputPort {
  int getPortNumber() {
    return 0;
  }
}

class MidiDevice {
  int _id;

  MidiDevice(this._id);

  openInputPort(int port) {}
  MidiOutputPort openOutputPort(int port) {
    return null;
  }

  DeviceInfo getInfo() {
    return null;
  }

  close() {}
}

class Midi {
  /// Gets the list of midi devices present on the system
  Future<List<DeviceInfo>> listDevices() async {
    var result = await _channel.invokeMethod('listDevices') as List;
    return result.map((res) {
      return new DeviceInfo(res);
    }).toList();
  }

  Future<MidiDevice> openDevice(DeviceInfo d) async {
    var result = await _channel.invokeMethod('openDevice', d.id);
  }
}
