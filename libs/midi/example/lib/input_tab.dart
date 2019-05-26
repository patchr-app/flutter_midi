import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:midi/midi.dart';
import 'package:provider/provider.dart';

class InputTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Midi midi = Provider.of<Midi>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Inputs'),
      ),
      body: FutureBuilder<List<MidiInputPort>>(
        future: midi.inputs,
        initialData: [],
        builder: (BuildContext context,
                AsyncSnapshot<List<MidiInputPort>> snapshot) =>
            ListView(
              children: snapshot.data
                  .map(
                    (MidiInputPort port) => ListTile(
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
