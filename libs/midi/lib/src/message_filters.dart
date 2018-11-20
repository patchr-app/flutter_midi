part of midi;

/// Converts a stream of raw midi data into discreet midi messages
class MessageSplitter extends StreamTransformerBase<Uint8List, Uint8List> {
  Stream<Uint8List> bind(Stream<Uint8List> stream) async* {
    List<int> buffer = [];
    int bytesRemaining = 0;
    bool sysExInProgress = false;
    await for (var chunk in stream) {
      int i = 0;
      if (sysExInProgress) {
        // look for the end byte
        var endIndex = chunk.indexOf(SYS_EX_END);
        if (endIndex > i) {
          buffer.addAll(chunk.sublist(0, endIndex + 1));
          yield (Uint8List.fromList(buffer));
          buffer = [];
          i = endIndex + 1;
          sysExInProgress = false;
        } else {
          buffer.addAll(chunk.sublist(i));
          i = chunk.length;
        }
      } else if (bytesRemaining > 0) {
        if (chunk.length >= bytesRemaining) {
          buffer.addAll(chunk.sublist(0, bytesRemaining));
          i = bytesRemaining;
          bytesRemaining = 0;
        }
      }
      while (i < chunk.length) {
        if (chunk[i] == CLOCK_MESSAGE) {
          yield chunk.sublist(i, i + 1);
          i++;
        } else if (chunk[i] >= NOTE_OFF && chunk[i] < PROGRAM_CHANGE) {
          yield chunk.sublist(i, i + 3);
          i += 3;
        } else if (chunk[i] >= PROGRAM_CHANGE && chunk[i] < PITCH_BEND) {
          yield chunk.sublist(i, i + 2);
          i += 2;
        } else if (chunk[i] >= PITCH_BEND && chunk[i] < 0xF0) {
          yield chunk.sublist(i, i + 3);
          i += 3;
        } else if (chunk[i] == TIME) {
          yield chunk.sublist(i, i + 2);
          i += 2;
        } else if (chunk[i] == SONG_POSITION) {
          yield chunk.sublist(i, i + 3);
          i += 2;
        } else if (chunk[i] == SONG_SELECT) {
          yield chunk.sublist(i, i + 2);
          i += 2;
        } else if (chunk[i] == TUNE_REQUEST) {
          yield chunk.sublist(i, i + 1);
          i += 1;
        } else if (chunk[i] == SYS_EX_START) {
          // can we emit the entire message at once?
          var endIndex = chunk.sublist(i).indexOf(SYS_EX_END);
          if (endIndex > i) {
            yield chunk.sublist(i, endIndex + 1);
            i = endIndex + 1;
          } else {
            sysExInProgress = true;
            buffer.addAll(chunk.sublist(i));
            i = chunk.length;
          }
        } else {
          // if we get here we received something we don't understand,
          // and that we weren't expecting, so drop the message
        }
      }
    }
  }
}

Function excludeClock = (List message) => message[0] != CLOCK_MESSAGE;
