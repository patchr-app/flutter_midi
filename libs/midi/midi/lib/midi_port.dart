part of midi;

enum MidiPortConnectionState {
  open,
  closed,
  pending,
}

enum MidiPortType {
  destination,
  source,
}

class MidiMessage {
  MidiMessage({this.data, this.timestamp});
  final Uint8List data;
  final double timestamp;
}

abstract class MidiPort {
  MidiPort(
    this.id, {
    this.manufacturer,
    this.name,
    this.type,
    this.version,
    this.number,
  }) {
    _connectionController.add(MidiPortConnectionState.closed);
    _stateController.add(MidiPortDeviceState.connected);

    _events = MidiPlatform.instance
        .deviceEvents()
        .where((dynamic args) => args['id'] == id)
        .listen((dynamic args) {
      if (args[state] == Constants.connected) {
        _stateController.add(MidiPortDeviceState.connected);
        _connectionController.add(MidiPortConnectionState.closed);
      } else {
        _stateController.add(MidiPortDeviceState.disconnected);
        _connectionController.add(MidiPortConnectionState.closed);
      }
    });
  }

  final StreamController<MidiPortConnectionState> _connectionController =
      StreamController<MidiPortConnectionState>.broadcast();
  final StreamController<MidiPortDeviceState> _stateController =
      StreamController<MidiPortDeviceState>.broadcast();

  Stream<MidiPortConnectionState> get connection =>
      _connectionController.stream;
  Stream<MidiPortDeviceState> get state => _stateController.stream;

  final String id;
  final String manufacturer;
  final String name;
  final MidiPortType type;
  final String version;
  final int number;

  StreamSubscription<dynamic> _events;

  void dispose() {
    _connectionController.close();
    _stateController.close();
    _events.cancel();
  }

  Future<void> close();
  Future<void> open();
}

/// A midi port for sending data to
class MidiDestinationPort extends MidiPort {
  MidiDestinationPort(
    String id, {
    String manufacturer,
    String name,
    String version,
    int number,
  }) : super(
          id,
          manufacturer: manufacturer,
          name: name,
          version: version,
          type: MidiPortType.destination,
          number: number,
        );

  @override
  bool operator ==(dynamic other) =>
      other is MidiDestinationPort && id == other.id;

  @override
  Future<void> open() async {
    _connectionController.add(MidiPortConnectionState.pending);
    await MidiPlatform.instance.openDestination(id);
    _connectionController.add(MidiPortConnectionState.open);
  }

  @override
  Future<void> close() async {
    await MidiPlatform.instance.closeDestination(id);
    _connectionController.add(MidiPortConnectionState.closed);
  }

  /// Send data do this midi port
  Future<void> send(Uint8List message) {
    return MidiPlatform.instance.send(id, message);
  }

  @override
  int get hashCode => id.hashCode;
}

class MidiSourcePort extends MidiPort {
  MidiSourcePort(String id, {String manufacturer, String name, String version})
      : super(id,
            manufacturer: manufacturer,
            name: name,
            version: version,
            type: MidiPortType.source);

  @override
  Future<void> open() async {
    _connectionController.add(MidiPortConnectionState.pending);
    await MidiPlatform.instance.openSource(id);
    _connectionController.add(MidiPortConnectionState.open);
  }

  @override
  Future<void> close() async {
    await MidiPlatform.instance.closeSource(id);
    _connectionController.add(MidiPortConnectionState.closed);
  }

  Stream<Uint8List> get messages {
    return MidiPlatform.instance
        .midiMessages()
        .where((dynamic data) => data[Constants.port] == id)
        .map<Uint8List>((dynamic data) => data[Constants.data])
        .transform(MessageSplitter());
  }
}
