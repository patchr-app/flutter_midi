# Midi IO

Send and receive Midi Messages on Android, iOS, and MacOS!

This plugin provides flutter bindings to interact with MIDI devices.
The API design is draws heavily from the [Web MIDI](https://www.w3.org/TR/webmidi/) spec, providing a common API
that wraps [Core Midi](https://developer.apple.com/documentation/coremidi/) on iOS and MacOS,
and [androidx.media.midi](https://developer.android.com/reference/android/media/midi/package-summary) on Android.

## Terminology

In order to provide a unified, platform agnostic Flutter API, the plugin uses the following terms:

- **Device** A device is Midi hardware or software that provides one or more Midi input and output ports. This plugin abstracts Devices away from you and simply provides a unified list of source and destination ports you can read from and write to. If you are coming from Web MIDI or Core MIDI this is regular practice, but Android has the Device abstraction, so this way of working may be new.

- **Source** A Source is a port your app can listen to midi messages _from_. This is equivalent to a `MIDIInput` in WebMIDI.

- **Destination** A Destination is a port your app can send messages _to_. This is equivalent to a `MIDIOutput` in WebMIDI.

## Getting Started

The `Midi` class is the main entry point into the MIDI system.

```dart
final midi = Midi():
```

## Listing Connected Ports

You can get the list of connected sources and destinations like so:

```dart
final midi = Midi();

final List<MidiSourcePort> sources = await midi.getSources();
final List<MidiDestinationPort> destinations = await midi.getDestinations();
```

In addition, you can also listen to a stream of connection events that occur when devices are plugged in and unplugged:

```dart
await for (ConnectionEvent event in midi.onDevicesChanged) {
  // process event
}
```

Use cases for the `onDevicesChanged` stream include automatically connecting to a particular device, etc.

## Sending Messages

To send midi messages to an DestinationPort, first open it, then use the send method:

```dart
final List<MidiDestinationPort> destinations = await midi.getDestinations();
final myDestination = destinations.first;
await myDestination.open();

// Key down on middle C
await myDestination.send([0x90, 0x3C, 0x40]);
```

## Listening to Messages

Listening to messages from a Midi Source requires opening and subscribing to the `messages` Stream:

```dart
final List<MidiSourcePort> sources = await midi.getSources();
final mySource = sources.first;
await mySource.open();

await for (let message of mySource.messages) {
  // process Midi message here
}
```

### Filtering

Since messages are sent as a Stream, you can filter midi messages using standard Dart techniques.

For example, we provide a built in filter to hide MIDI clock messages:

```dart
await for (let message of mySource.messages.where(excludeClock)) {
  // process Midi message here
}
```

## Contributing

This plugin is a work in progress, and due to the scope of how MIDI can be used, and different platform specifics, There's plenty of room to help. Bug reports and Pull Requests are welcome!
