part of midi;

class MidiDevice {
  int _id;
  bool _open;

  MidiDevice(this._id) {
    this._open = true;
  }

  Future<MidiOutputPort> openOutputPort(PortInfo p) async {
    int portId = await _channel.invokeMethod(
        'openOutputPort', {'deviceId': this._id, 'port': p.number});
    return MidiOutputPort(this, p.number, portId, info: p);
  }

  Future<MidiInputPort> openInputPort(PortInfo p) async {
    int portId = await _channel.invokeMethod(
        'openInputPort', {'deviceId': this._id, 'port': p.number});
    return MidiInputPort(this, p.number, portId, info: p);
  }

  close() async {
    await _channel.invokeMethod('closeDevice', this._id);
    this._open = false;
  }
}
