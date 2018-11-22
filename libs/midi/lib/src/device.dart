part of midi;

class MidiDevice {
  int _id;
  bool _open;

  MidiDevice(this._id) {
    this._open = true;
  }

  Future<MidiOutputPort> openOutputPort(int port) async {
    int portId = await _channel
        .invokeMethod('openOutputPort', {'deviceId': this._id, 'port': port});
    return MidiOutputPort(this, port, portId);
  }

  Future<MidiInputPort> openInputPort(int port) async {
    int portId = await _channel
        .invokeMethod('openInputPort', {'deviceId': this._id, 'port': port});
    return MidiInputPort(this, port, portId);
  }

  close() async {
    await _channel.invokeMethod('closeDevice', this._id);
    this._open = false;
  }
}
