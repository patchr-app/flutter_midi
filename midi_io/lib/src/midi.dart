import 'dart:async';
import 'package:midi_io_platform_interface/midi_io_platform_interface.dart';

import 'connection_event.dart';
import 'midi_port.dart';

class Midi {
  Future<List<MidiSourcePort>> getSources() async {
    final List<Map<dynamic, dynamic>> info = await (MidiPlatform.instance
        .getSources() as FutureOr<List<Map<dynamic, dynamic>>>);

    return info.map((Map<dynamic, dynamic> device) {
      return MidiSourcePort(device[Constants.id],
          manufacturer: device[Constants.manufacturer],
          name: device[Constants.name],
          version: device[Constants.version]);
    }).toList();
  }

  Future<List<MidiDestinationPort>> getDestinations() async {
    final List<Map<dynamic, dynamic>> info = await (MidiPlatform.instance
        .getDestinations() as FutureOr<List<Map<dynamic, dynamic>>>);

    return info.map((Map<dynamic, dynamic> device) {
      return MidiDestinationPort(device[Constants.id],
          manufacturer: device[Constants.manufacturer],
          name: device[Constants.name],
          version: device[Constants.version]);
    }).toList();
  }

  Stream<ConnectionEvent> get onDevicesChanged {
    return MidiPlatform.instance.deviceEvents().map((dynamic event) {
      return ConnectionEvent.fromMap(event);
    });
  }
}