import 'package:flutter/material.dart';
import 'package:midi/midi.dart';
import 'midi_provider.dart';
import 'dart:async';

class OutputPortPage extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final PortInfo portInfo;
  OutputPortPage({this.deviceInfo, this.portInfo});
  createState() {
    return OutputPortPageState();
  }
}

class OutputPortPageState extends State<OutputPortPage> {
  MidiDevice device;
  MidiOutputPort port;
  List<String> messages = [];
  StreamSubscription messageSub;

  void initState() {
    super.initState();
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    connect();
  }

  connect() async {
    Midi midi = MidiProvider.of(context).midi;
    device = await midi.openDevice(widget.deviceInfo);
    port = await device.openOutputPort(widget.portInfo.number);

    messageSub = port.messages.where(excludeClock).listen((data) {
      this.setState(() {
        messages.insert(0, data.toString());
      });
    });
  }

  dispose() {
    super.dispose();
    this.messageSub.cancel();
    this.port.close();
    this.device.close();
  }

  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Output Port'),
      ),
      body: ListView(
        children: messages.map((message) => Text(message)).toList(),
      ),
    );
  }
}
