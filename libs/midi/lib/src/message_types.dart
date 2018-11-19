part of midi;

/// Midi message types
enum MidiMessageType {
  NOTE_OFF,
  NOTE_ON,
  POLYPHONIC_AFTERTOUCH,
  CONTROL_CHANGE,
  PROGRAM_CHANGE,
  CHANNEL_PRESSURE,
  PITCH_BEND,
  SOUND_OFF,
  RESET_CONTROLLERS,
  LOCAL_CONTROL,
  ALL_NOTES_OFF,
  SYSTEM_EXCLUSIVE,
  TIME,
  SONG_POSITION,
  SONG_SELECT,
  TUNE_REQUEST,
  CLOCK,
  START,
  CONTINUE,
  STOP,
  PING,
  RESET
}
