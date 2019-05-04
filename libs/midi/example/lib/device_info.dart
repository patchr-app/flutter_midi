import 'package:flutter/material.dart';
import 'package:midi/midi.dart';
import './output_port.dart';

class DeviceInfoPage extends StatelessWidget {
  final DeviceInfo device;

  DeviceInfoPage(this.device);

  openOutputPort(BuildContext context, PortInfo portInfo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => OutputPortPage(
              deviceInfo: this.device,
              portInfo: portInfo,
            ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.product),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.home),
            title: Text(device.manufacturer),
            subtitle: Text('Manufacturer'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text(device.name),
            subtitle: Text('Name'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_basket),
            title: Text(device.product),
            subtitle: Text('Product'),
          ),
          ListTile(
            leading: Icon(Icons.usb),
            title: Text(device.type),
            subtitle: Text('Type'),
          ),
          ListTile(
            leading: Icon(Icons.settings_input_svideo),
            title: Text(device.serialNumber ?? 'Not Set'),
            subtitle: Text('Serial Number'),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text(device.version ?? 'Not Set'),
            subtitle: Text('Version'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Text(
              'Ports',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
          for (PortInfo info in device.ports)
            (info.type == PortType.output)
                ? ListTile(
                    leading: Icon(info.type == PortType.output
                        ? Icons.file_upload
                        : Icons.file_download),
                    subtitle: Text(info.name ?? ''),
                    title: Text('Output' + ' ' + info.number.toString()),
                    onTap: () => openOutputPort(context, info),
                  )
                : ListTile(
                    leading: Icon(Icons.file_download),
                    subtitle: Text(info.name ?? ''),
                    title: Text('Input' + ' ' + info.number.toString()),
                  ),
        ],
      ),
    );
  }
}
