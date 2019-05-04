import 'package:flutter/material.dart';

import './device_info.dart';
import './midi_provider.dart';
import 'package:midi/midi.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Midi midi;

  @override
  void initState() {
    super.initState();
    this.midi = new Midi();
  }

  openDevice(BuildContext context, DeviceInfo device) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => new DeviceInfoPage(device)));
  }

  @override
  Widget build(BuildContext context) {
    return MidiProvider(
      midi: midi,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('MIDI Example App'),
          ),
          body: StreamBuilder(
              stream: midi.devices(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DeviceInfo>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return (snapshot.data.length > 0)
                    ? ListView(
                        children: snapshot.data
                            .map(
                              (DeviceInfo d) => Card(
                                    child: ListTile(
                                      title: Text(d.name),
                                      subtitle: Text(d.manufacturer),
                                      onTap: () {
                                        openDevice(context, d);
                                      },
                                    ),
                                  ),
                            )
                            .toList())
                    : Center(
                        child: Text('No devices'),
                      );
              }),
        ),
      ),
    );
  }
}
