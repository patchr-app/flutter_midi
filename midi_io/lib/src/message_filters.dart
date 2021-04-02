import 'dart:typed_data';

import 'message_types.dart';

Function excludeClock = (Uint8List message) => message[0] != CLOCK_MESSAGE;
