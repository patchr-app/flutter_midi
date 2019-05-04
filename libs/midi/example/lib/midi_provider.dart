import 'package:flutter/material.dart';
import 'package:midi/midi.dart';

class MidiProvider extends InheritedWidget {
  final Midi midi;

  MidiProvider({this.midi, Widget child, Key key})
      : super(key: key, child: child);

  static MidiProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MidiProvider) as MidiProvider;
  }

  bool updateShouldNotify(MidiProvider old) => midi != old.midi;
}
