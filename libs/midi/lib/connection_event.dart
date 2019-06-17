part of midi;

enum MidiPortDeviceState {
  disconnected,
  connected,
}

class ConnectionEvent {
  ConnectionEvent({
    @required this.id,
    @required this.state,
    @required this.type,
    @required this.port,
  });

  factory ConnectionEvent.fromMap(Map<dynamic, dynamic> data) {
    final Map<dynamic, dynamic> port = data[Constants.port];
    return ConnectionEvent(
        id: data[Constants.id],
        port: port[Constants.type] == Constants.input
            ? MidiInputPort(port[Constants.id],
                manufacturer: port[Constants.manufacturer],
                name: port[Constants.name],
                version: port[Constants.version])
            : MidiOutputPort(port[Constants.id],
                manufacturer: port[Constants.manufacturer],
                name: port[Constants.name],
                version: port[Constants.version]),
        type: data[Constants.type] == Constants.input
            ? MidiPortType.input
            : MidiPortType.output,
        state: data[Constants.state] == Constants.connected
            ? MidiPortDeviceState.connected
            : MidiPortDeviceState.disconnected);
  }

  final String id;
  final MidiPortDeviceState state;
  final MidiPortType type;
  final MidiPort port;
}
