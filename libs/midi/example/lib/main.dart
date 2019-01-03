import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:midi/midi.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<DeviceInfo> _devices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var devices;
    try {
      Midi m = new Midi();
      print('Looking for devices');
      devices = await m.listDevices();
      print('Found ${devices.length} devices');
      for (final DeviceInfo dev in devices) {
        print('ID:               ${dev.id}');
        print('Name:             ${dev.name}');
        print('Manufacturer:     ${dev.manufacturer}');
        print('Type:             ${dev.type}');
        print('Product:          ${dev.product}');
        print('Serial:           ${dev.serialNumber}');
        print('Version:          ${dev.version}');
        print('Num Input Ports:  ${dev.inputPortCount}');
        print('Num Output Ports: ${dev.outputPortCount}');
        for (final PortInfo p in dev.ports) {
          print("${p.type} Port:");
          print('  Number: ${p.number}');
          print('  Name:   ${p.name}');
        }
      }
      if (devices.length > 0) {
        //print('Attempting to connect');
        //var device = await m.openDevice(devices[0]);
        //print('Connected!');

        //print('opening output port 0');
        //var port = await device.openOutputPort(1);
        //port = await device.openOutputPort(0);

        //print('listening to messages');
        //port.messages.where(excludeClock).forEach((data) => print(data));
      }
    } on PlatformException {
      print("exception");
      devices = [];
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: (_devices.length > 0)
              ? ListView(
                  children: _devices
                      .map((DeviceInfo d) => Card(
                              child: ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.manufacturer),
                          )))
                      .toList())
              : Center(
                  child: Text('No devices'),
                )),
    );
  }
}
