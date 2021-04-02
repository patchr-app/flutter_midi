package app.patchr.midi;

import android.media.midi.MidiReceiver;

public abstract class FlutterMidiReceiver extends MidiReceiver {
  String id;
  FlutterMidiReceiver(String id) {
    this.id = id;
  }
}
