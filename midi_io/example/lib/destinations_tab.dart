import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:midi_io/midi_io.dart';
import 'package:provider/provider.dart';

class DestinationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Midi midi = Provider.of<Midi>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
      ),
      body: FutureBuilder<List<MidiDestinationPort>>(
        future: midi.getDestinations(),
        initialData: const [],
        builder: (BuildContext context,
                AsyncSnapshot<List<MidiDestinationPort>> snapshot) =>
            ListView(
          children: snapshot.data
              .map(
                (MidiDestinationPort port) => ListTile(
                  title: Text(port.name),
                  subtitle: Text(port.manufacturer),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
