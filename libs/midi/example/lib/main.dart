import 'package:flutter/material.dart';

import 'package:midi/midi.dart';
import 'package:provider/provider.dart';

import './input_tab.dart';
import './output_tab.dart';

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
        builder: (BuildContext context) => Midi(),
        child: MaterialApp(
          home: Scaffold(
            body: tabIndex == 0 ? InputTab() : OutputTab(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (int index) => setTab(index),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.file_download),
                  title: Text('Inputs'),
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.file_upload),
                  title: Text('Outputs'),
                ),
              ],
            ),
          ),
        ));
  }
}
