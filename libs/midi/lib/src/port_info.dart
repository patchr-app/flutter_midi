part of midi;

enum PortType { input, output }

/// Information about a port contained in a device
class PortInfo {
  String name;
  int number;
  PortType type;

  PortInfo(Map props) {
    props.forEach((key, val) => print('$key : $val'));
    this.name = props['name'];
    this.number = props['number'];
    this.type = props['type'] == 'INPUT' ? PortType.input : PortType.output;
  }

  toJson() {
    return {'name': name, 'number': number, 'type': type};
  }
}
