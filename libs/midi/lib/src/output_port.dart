part of midi;

class MidiOutputPort {
  MidiDevice parent;
  int portNumber;
  int _identifier;

  MidiOutputPort(this.parent, this.portNumber, this._identifier) {
    print('  Unique ID: ${this._identifier}');
    print('  Port:      ${this.portNumber}');
  }

  Future<void> close() {
    return _channel.invokeMethod(
        'closeOutputPort', {'deviceId': parent._id, 'port': this.portNumber});
  }

  Stream<Uint8List> get messages {
    return _midiMessagechannel
        .receiveBroadcastStream()
        //.where((data) => data['port'] == this._identifier)
        .map((data) => data['data'] as Uint8List)
        .transform(MessageSplitter());
  }
}
