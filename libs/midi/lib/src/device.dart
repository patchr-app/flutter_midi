part of midi;

class MidiDevice {
  int _id;
  bool _open;

  MidiDevice(this._id) {
    this._open = true;
  }

  openInputPort(int port) {}

  Future<MidiOutputPort> openOutputPort(int port) async {
    await _channel
        .invokeMethod('openOutputPort', {'deviceId': this._id, 'port': port});
    return MidiOutputPort(this, port);
  }

  close() async {
    await _channel.invokeMethod('closeDevice', this._id);
    this._open = false;
  }
}
