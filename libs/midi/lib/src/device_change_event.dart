part of midi;

enum MidiDeviceChangeType { Added, Removed }

class MidiDeviceChangeEvent {
  MidiDeviceChangeType type;
  DeviceInfo device;

  MidiDeviceChangeEvent(Map props) {
    type = props['type'] == 'DEVICE_ADDED'
        ? MidiDeviceChangeType.Added
        : MidiDeviceChangeType.Removed;
    device = new DeviceInfo(props['device']);
  }
}
