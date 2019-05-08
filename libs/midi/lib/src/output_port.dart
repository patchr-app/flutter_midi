part of midi;

class MidiOutputPort {
  MidiDevice parent;
  PortInfo info;
  int portNumber;
  int _identifier;

  MidiOutputPort(this.parent, this.portNumber, this._identifier, {this.info}) {
    print('  Unique ID: ${this._identifier}');
    print('  Port:      ${this.portNumber}');
  }

  Future<void> close() {
    return _channel.invokeMethod('closeOutputPort', this._identifier);
  }

  Stream<Uint8List> get messages {
    return _midiMessagechannel
        .receiveBroadcastStream()
        .where((data) => data['port'] == this._identifier)
        .map((data) => data['data'] as Uint8List)
        .transform(MessageSplitter());
  }
}
