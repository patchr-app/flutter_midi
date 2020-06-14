import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_midi.dart';

/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `midi`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [MidiPlatform] methods.
abstract class MidiPlatform extends PlatformInterface {
  /// Constructs a UrlLauncherPlatform.
  MidiPlatform() : super(token: _token);

  static final Object _token = Object();

  static MidiPlatform _instance = MethodChannelMidi();

  /// The default instance of [MidiPlatform] to use.
  ///
  /// Defaults to [MethodChannelUrlLauncher].
  static MidiPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MidiPlatform] when they register themselves.
  static set instance(MidiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Map<dynamic, dynamic>>> getInputs() {
    throw UnimplementedError('getInputs() has not been implemented.');
  }

  Future<List<Map<dynamic, dynamic>>> getOutputs() {
    throw UnimplementedError('getOutputs() has not been implemented.');
  }

  Future<void> openInput(String id) {
    throw UnimplementedError('openInput() has not been implemented.');
  }

  Future<void> openOutput(String id) {
    throw UnimplementedError('openOutput() has not been implemented.');
  }

  Future<void> closeInput(String id) {
    throw UnimplementedError('closeInput() has not been implemented.');
  }

  Future<void> closeOutput(String id) {
    throw UnimplementedError('closeOutput() has not been implemented.');
  }

  Future<void> send(String id, Uint8List message) {
    throw UnimplementedError('send() has not been implemented.');
  }

  Stream<dynamic> deviceEvents() {
    throw UnimplementedError('deviceEvents() has not been implemented.');
  }

  Stream<dynamic> midiMessages() {
    throw UnimplementedError('midiMessages() has not been implemented.');
  }
}
