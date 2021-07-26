import 'package:flutter/material.dart';

import 'package:midi_io/midi_io.dart';
import 'package:provider/provider.dart';

import './destinations_tab.dart';
import './sources_tab.dart';

void main() => runApp(MidiExample());

class MidiExample extends StatefulWidget {
  @override
  State createState() {
    return MidiExampleState();
  }
}

class MidiExampleState extends State<MidiExample> {
  int tabIndex = 0;

  void setTab(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Midi>(
        create: (BuildContext context) => Midi(),
        child: MaterialApp(
          home: Scaffold(
            body: tabIndex == 0 ? DestinationsTab() : SourcesTab(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (int index) => setTab(index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_upload),
                  label: 'Destinations',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_download),
                  label: 'Sources',
                ),
              ],
            ),
          ),
        ));
  }
}
