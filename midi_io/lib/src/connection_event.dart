import 'package:midi_io_platform_interface/midi_io_platform_interface.dart';
import 'midi_port.dart';

enum MidiPortDeviceState {
  disconnected,
  connected,
}

class ConnectionEvent {
  ConnectionEvent({
    required this.id,
    required this.state,
    required this.type,
    required this.port,
  });

  factory ConnectionEvent.fromMap(Map<dynamic, dynamic> data) {
    final Map<dynamic, dynamic> port = data[Constants.port];
    return ConnectionEvent(
        id: data[Constants.id],
        port: port[Constants.type] == Constants.destination
            ? MidiDestinationPort(port[Constants.id],
                manufacturer: port[Constants.manufacturer],
                name: port[Constants.name],
                version: port[Constants.version])
            : MidiSourcePort(port[Constants.id],
                manufacturer: port[Constants.manufacturer],
                name: port[Constants.name],
                version: port[Constants.version]),
        type: data[Constants.type] == Constants.destination
            ? MidiPortType.destination
            : MidiPortType.source,
        state: data[Constants.state] == Constants.connected
            ? MidiPortDeviceState.connected
            : MidiPortDeviceState.disconnected);
  }

  final String? id;
  final MidiPortDeviceState state;
  final MidiPortType type;
  final MidiPort port;
}
