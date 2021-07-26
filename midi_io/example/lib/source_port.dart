import 'dart:async';
import 'package:flutter/material.dart';
import 'package:midi_io/midi_io.dart';

class SourcePortPage extends StatefulWidget {
  const SourcePortPage({required this.port});
  final MidiSourcePort port;

  @override
  State<SourcePortPage> createState() {
    return SourcePortPageState();
  }
}

class SourcePortPageState extends State<SourcePortPage> {
  List<String> messages = [];
  StreamSubscription? messageSub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
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

  @override
  void dispose() {
    messageSub?.cancel();
    widget.port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Source Port'),
      ),
      body: ListView(
        children: messages.map((message) => Text(message)).toList(),
      ),
    );
  }
}
