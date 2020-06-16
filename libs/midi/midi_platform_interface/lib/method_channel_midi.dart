import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:midi_platform_interface/method_channel_constants.dart';

import 'midi_platform_interface.dart';

/// Method channel used for all midi related stuff
const MethodChannel _methodChannel = MethodChannel(Constants.methodChannelName);

const EventChannel _deviceEventchannel =
    EventChannel(Constants.deviceChannelName);

const EventChannel _midiMessagechannel =
    EventChannel(Constants.messageChannelName);

/// An implementation of [UrlLauncherPlatform] that uses method channels.
class MethodChannelMidi extends MidiPlatform {
  final _midiMessageStream = _midiMessagechannel.receiveBroadcastStream();
  final _deviceEventStream = _deviceEventchannel.receiveBroadcastStream();

  @override
  Future<List<Map<dynamic, dynamic>>> getDestinations() {
    return _methodChannel
        .invokeListMethod<Map<dynamic, dynamic>>(Constants.getInputs);
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getSources() {
    return _methodChannel
        .invokeListMethod<Map<dynamic, dynamic>>(Constants.getOutputs);
  }

  @override
  Future<void> openDestination(String id) {
    return _methodChannel.invokeMethod<void>(Constants.openInput, id);
  }

  @override
  Future<void> openSource(String id) {
    return _methodChannel.invokeMethod<void>(Constants.openOutput, id);
  }

  @override
  Future<void> closeDestination(String id) {
    return _methodChannel.invokeMethod<void>(Constants.closeInput, id);
  }

  @override
  Future<void> closeSource(String id) {
    return _methodChannel.invokeMethod<void>(Constants.closeOutput, id);
  }

  @override
  Future<void> send(String id, Uint8List message) {
    return _methodChannel.invokeMethod(Constants.send, <String, dynamic>{
      Constants.port: id,
      Constants.data: message,
    });
  }

  @override
  Stream<dynamic> deviceEvents() {
    return _deviceEventStream;
  }

  @override
  Stream<dynamic> midiMessages() {
    return _midiMessageStream;
  }
}
