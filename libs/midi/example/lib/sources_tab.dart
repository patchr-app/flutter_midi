import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:midi/midi.dart';
import 'package:provider/provider.dart';
import 'source_port.dart';

class SourcesTab extends StatelessWidget {
  void openSource(BuildContext context, MidiSourcePort port) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (BuildContext context) => SourcePortPage(
          port: port,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Midi midi = Provider.of<Midi>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources'),
      ),
      body: FutureBuilder<List<MidiSourcePort>>(
        future: midi.getSources(),
        initialData: const [],
        builder: (BuildContext context,
                AsyncSnapshot<List<MidiSourcePort>> snapshot) =>
            ListView(
          children: snapshot.data
              .map(
                (MidiSourcePort port) => ListTile(
                  title: Text(port.name),
                  subtitle: Text(port.manufacturer),
                  onTap: () => openSource(context, port),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
