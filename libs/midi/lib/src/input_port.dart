part of midi;

class MidiInputPort {
  MidiDevice parent;
  int portNumber;
  int _identifier;

  MidiInputPort(this.parent, this.portNumber, this._identifier) {
    print('  Unique ID: ${this._identifier}');
    print('  Port:      ${this.portNumber}');
  }

  /// close the port
  Future<void> close() {
    return _channel.invokeMethod('closeInputPort', this._identifier);
  }

  /// Send data do this midi port
  Future<void> send(Uint8List data) {
    return _channel
        .invokeMethod('send', {'port': this._identifier, 'data': data});
  }
}
