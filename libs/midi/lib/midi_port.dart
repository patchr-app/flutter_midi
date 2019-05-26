part of midi;

enum MidiPortConnectionState {
  open,
  closed,
  pending,
}

enum MidiPortType {
  input,
  output,
}

class MidiMessage {
  MidiMessage({this.data, this.timestamp});
  final Uint8List data;
  final double timestamp;
}

abstract class MidiPort {
  MidiPort(this.id,
      {this.manufacturer, this.name, this.type, this.version, this.number}) {
    _connectionController.add(MidiPortConnectionState.closed);
    _stateController.add(MidiPortDeviceState.connected);

    _deviceEvents = _deviceEventchannel
        .receiveBroadcastStream()
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

  StreamSubscription _deviceEvents;

  void dispose() {
    _connectionController.close();
    _stateController.close();
    _deviceEvents.cancel();
  }

  Future<void> close();
  Future<void> open();
}

class MidiInputPort extends MidiPort {
  MidiInputPort(String id,
      {String manufacturer, String name, String version, int number})
      : super(
          id,
          manufacturer: manufacturer,
          name: name,
          version: version,
          type: MidiPortType.input,
          number: number,
        );

  @override
  Future<void> open() async {
    _connectionController.add(MidiPortConnectionState.pending);
    await _methodChannel.invokeMethod<void>(Constants.openInput, id);
    _connectionController.add(MidiPortConnectionState.open);
  }

  @override
  Future<void> close() async {
    await _methodChannel.invokeMethod<void>(Constants.closeInput, id);
    _connectionController.add(MidiPortConnectionState.closed);
  }

  /// Send data do this midi port
  Future<void> send(Uint8List message) {
    return _methodChannel.invokeMethod(Constants.send,
        <String, dynamic>{Constants.port: id, Constants.data: message});
  }
}

class MidiOutputPort extends MidiPort {
  MidiOutputPort(String id, {String manufacturer, String name, String version})
      : super(id,
            manufacturer: manufacturer,
            name: name,
            version: version,
            type: MidiPortType.output);

  @override
  Future<void> open() async {
    _connectionController.add(MidiPortConnectionState.pending);
    await _methodChannel.invokeMethod<void>(Constants.openOutput, id);
    _connectionController.add(MidiPortConnectionState.open);
  }

  @override
  Future<void> close() async {
    await _methodChannel.invokeMethod<void>(Constants.closeOutput, id);
    _connectionController.add(MidiPortConnectionState.closed);
  }

  Stream<Uint8List> get messages {
    return _midiMessagechannel
        .receiveBroadcastStream()
        .where((dynamic data) => data[Constants.port] == id)
        .map((dynamic data) => data[Constants.data] as Uint8List)
        .transform(MessageSplitter());
  }
}