part of midi;

class MidiOutputPort {
  MidiDevice parent;
  int portNumber;

  MidiOutputPort(this.parent, this.portNumber);

  Future<void> close() {
    return _channel.invokeMethod(
        'closeOutputPort', {'deviceId': parent._id, 'port': this.portNumber});
  }

  Stream<Uint8List> listen() {
    return _midiMessagechannel.receiveBroadcastStream().where((data) =>
        data['device'] == parent._id && data['port'] == this.portNumber);
  }
}
