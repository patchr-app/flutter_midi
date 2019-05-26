import 'package:flutter/material.dart';
import 'package:midi/midi.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class OutputPortPage extends StatefulWidget {
  OutputPortPage({this.port});
  final MidiOutputPort port;

  createState() {
    return OutputPortPageState();
  }
}

class OutputPortPageState extends State<OutputPortPage> {
  List<String> messages = [];
  StreamSubscription messageSub;

  void initState() {
    super.initState();
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    connect();
  }

  Future<void> connect() async {
    await widget.port.open();
    messageSub = widget.port.messages.where(excludeClock).listen((data) {
      setState(() {
        messages.insert(0, data.toString());
      });
    });
  }

  void dispose() {
    super.dispose();
    this.messageSub.cancel();
    widget.port.close();
  }

  Widget build(BuildContext context) {
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
