part of midi;

Function excludeClock = (Uint8List message) => message[0] != CLOCK_MESSAGE;
