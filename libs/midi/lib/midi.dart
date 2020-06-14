library midi;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part './connection_event.dart';
part './constants.dart';
part './message_filters.dart';
part './message_splitter.dart';
part './message_types.dart';
part './midi_port.dart';

/// Method channel used for all midi related stuff
const MethodChannel _methodChannel = MethodChannel(Constants.methodChannelName);
const EventChannel _deviceEventchannel =
    EventChannel(Constants.deviceChannelName);
const EventChannel _midiMessagechannel =
    EventChannel(Constants.messageChannelName);

Stream<dynamic> _deviceEvents = _deviceEventchannel.receiveBroadcastStream();
Stream<dynamic> _midiMessages = _deviceEventchannel.receiveBroadcastStream();

class Midi {
  Future<List<MidiSourcePort>> getSources() async {
    return outputs;
  }

  Future<List<MidiDestinationPort>> getDestinations() async {
    return inputs;
  }

  /// Gets the midi destinationports.
  /// Use [getDestinations] instead
  @deprecated
  Future<List<MidiDestinationPort>> get inputs async {
    final List<Map<dynamic, dynamic>> info = await _methodChannel
        .invokeListMethod<Map<dynamic, dynamic>>(Constants.getInputs);

    return info.map((Map<dynamic, dynamic> device) {
      return MidiDestinationPort(device[Constants.id],
          manufacturer: device[Constants.manufacturer],
          name: device[Constants.name],
          version: device[Constants.version]);
    }).toList();
  }

  /// Gets the midi source ports.
  /// Use [getSources] instead
  @deprecated
  Future<List<MidiSourcePort>> get outputs async {
    final List<Map<dynamic, dynamic>> info = await _methodChannel
        .invokeListMethod<Map<dynamic, dynamic>>(Constants.getOutputs);

    return info.map((Map<dynamic, dynamic> device) {
      return MidiSourcePort(device[Constants.id],
          manufacturer: device[Constants.manufacturer],
          name: device[Constants.name],
          version: device[Constants.version]);
    }).toList();
  }

  Stream<ConnectionEvent> get onDevicesChanged {
    return _deviceEvents.map((dynamic event) {
      return ConnectionEvent.fromMap(event);
    });
  }
}
