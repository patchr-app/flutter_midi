package app.patchr.midi_io

import android.media.midi.MidiReceiver


abstract class FlutterMidiReceiver internal constructor(var id: String) : MidiReceiver()
