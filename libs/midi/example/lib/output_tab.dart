import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:midi/midi.dart';
import 'package:provider/provider.dart';
import 'output_port.dart';

class OutputTab extends StatelessWidget {
  void openOutputPort(BuildContext context, MidiOutputPort port) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (BuildContext context) => OutputPortPage(
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
        title: Text('Outputs'),
      ),
      body: FutureBuilder<List<MidiOutputPort>>(
        future: midi.outputs,
        initialData: [],
        builder: (BuildContext context,
                AsyncSnapshot<List<MidiOutputPort>> snapshot) =>
            ListView(
              children: snapshot.data
                  .map(
                    (MidiOutputPort port) => ListTile(
                          title: Text(port.name),
                          subtitle: Text(port.manufacturer),
                          onTap: () => openOutputPort(context, port),
                        ),
                  )
                  .toList(),
            ),
      ),
    );
  }
}
