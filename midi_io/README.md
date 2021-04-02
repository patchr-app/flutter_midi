# Midi IO

Midi IO is a [Web MIDI](https://developer.mozilla.org/en-US/docs/Web/API/MIDIAccess) inspired Flutter plugin for reading and sending data to MIDI devices. It abstracts away Android's [Midi](https://developer.android.com/reference/android/media/midi/package-summary) and Apple's [CoreMidi](https://developer.apple.com/documentation/coremidi/) and provides an easy to use, consistent API for interfacing with MIDI devices.

> **Under Development**
>
> This Plugin is under active development and may have bugs.
> Contributions in the form of code or bug reports are welcomed!

## Features

- A sane API that hides away platform inconsistencies
- Connect to any number of devices simultaneously
- Read MIDI messages using Dart Streams
- Write MIDI data as simple lists

## Getting Started

`Midi` is the starting point to working with the platform's MIDI system. You can instantiate this class by simply calling its constructor:

```dart
import 'package:midi_io/midi_io.dart';

final midi = Midi();
```

## Writing MIDI to devices

You write to a MIDI `MidiDestinationPort`.

This is the equivalent to [MIDIOutput] in WebMIDI, an `MidiInputPort` in Android, and a `Destination` in CoreMIDI. You can see the confusing inconsistencies between platforms. So, if you want to send data, you send it to a `DestinationPort`.

### Getting available destinations

You use `Midi` to get the list of destinations currently connected to the device:

```dart
final List<MidiDestinationPort> destinations = await midi.getDestinations();
```

You can enumerate this list to find a specific device. Note that on both Android and iOS, `port.id` changes based on the order devices are connected, whether they are disconnected and reconnected. So, the most reliable way to identify a port is by its `name`.

### Sending data

Once you have a port you can open it and send it data:

```dart
MidiDestinationPort p = destinations[0];
await p.open();
// send a note on message, Middle C, full volume
await p.send([0x90, 60, 127]);
```

## Reading From Midi Devices

You read from `MidiSourcePorts`. The process for finding and opening sources is similar to destinations:

```dart
final List<MidiSourcePort> sources = await midi.getSources();
```

### Listening to data

You subscribe to a Stream of messages to read from devices. This plugin automatically converts the raw byte stream into discreet MIDI messages for you.

```dart
MidiSourcePort p = sources[0];
await p.open();

Stream<Uint8List> data = p.messages;

await for (message in data) {
  print(data);
}
```

Depending on the device and your use case you might find this stream to be a bit noisy with MIDI Clock messages. In that case, you can take advantage of Stream filters to hide the messages you aren't interested in. The plugin provides a filter for removing Clock messages from the data.

```dart
Stream<Uint8List> data = p.messages.where( excludeClock );

await for (message in data) {
  // awesome, no more clock messages
  print(data);
}
```
