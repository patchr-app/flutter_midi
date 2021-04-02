import 'dart:typed_data';

import 'message_types.dart';

typedef MessageFilter = bool Function(Uint8List message);

/// A message filter that filters out midi clock messages
MessageFilter excludeClock = (Uint8List message) => message[0] != CLOCK_MESSAGE;
