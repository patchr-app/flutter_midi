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
  });

  final String id;
  final MidiPortDeviceState state;
  final MidiPortType type;
}
