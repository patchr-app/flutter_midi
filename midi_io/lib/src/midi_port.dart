import 'dart:async';
import 'dart:typed_data';

import 'package:midi_io_platform_interface/midi_io_platform_interface.dart';
import 'connection_event.dart';
import 'message_splitter.dart';

/// The connection state of a [MidiPort]
enum MidiPortConnectionState {
  /// The port is open and available for reading/writing
  open,

  /// The port is closed
  closed,

  /// A connection attempt is in progress
  pending,
}

/// The type of [MidiPort]
enum MidiPortType {
  destination,
  source,
}

/// A midi message
class MidiMessage {
  MidiMessage({
    this.data,
    this.timestamp,
  });

  /// The data contained in this message
  final Uint8List? data;

  /// The timestamp of the message
  final double? timestamp;
}

/// Base class for Midi ports
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

  /// Stream for listening to [MidiPortConnectionState] changes
  Stream<MidiPortConnectionState> get connection =>
      _connectionController.stream;

  /// Stream for listening to [MidiPortDeviceState] changes
  Stream<MidiPortDeviceState> get state => _stateController.stream;

  /// The ID of this midi device
  final String id;

  /// The manufacturer
  final String? manufacturer;

  /// The displayable name of the device
  final String? name;

  /// Whether this is an input or output port
  final MidiPortType? type;

  /// Device firmware version
  final String? version;

  /// Port number
  final int? number;

  late StreamSubscription<dynamic> _events;

  void dispose() {
    _connectionController.close();
    _stateController.close();
    _events.cancel();
  }

  /// Close this MidiPort
  Future<void> close();

  /// Attempt to open a connection to this MidiPort
  Future<void> open();
}

/// A midi port for sending data to
class MidiDestinationPort extends MidiPort {
  MidiDestinationPort(
    String id, {
    String? manufacturer,
    String? name,
    String? version,
    int? number,
  }) : super(
          id,
          manufacturer: manufacturer,
          name: name,
          version: version,
          type: MidiPortType.destination,
          number: number,
        );

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
  bool operator ==(dynamic other) =>
      other is MidiDestinationPort && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A [MidiPort] for reading data from.
class MidiSourcePort extends MidiPort {
  MidiSourcePort(String id,
      {String? manufacturer, String? name, String? version})
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

  /// The stream of Midi messages originating from this source port.
  Stream<Uint8List> get messages {
    Stream<Uint8List> stream = MidiPlatform.instance
        .midiMessages()
        .where((dynamic data) => data[Constants.port] == id)
        .map<Uint8List>((dynamic data) => data[Constants.data] as Uint8List);
    return stream.transform(MessageSplitter());
  }

  @override
  bool operator ==(dynamic other) => other is MidiSourcePort && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
