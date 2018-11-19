part of midi;

/// Information about a single midi device on the system
class DeviceInfo {
  int id;
  int inputPortCount;
  int outputPortCount;
  String type;
  String manufacturer;
  String name;
  String product;
  String serialNumber;
  String version;
  List<PortInfo> ports;

  DeviceInfo(Map props) {
    this.id = props['id'];
    this.inputPortCount = props['inputPortCount'];
    this.outputPortCount = props['outputPortCount'];
    this.type = props['type'];
    this.manufacturer = props['manufacturer'];
    this.name = props['name'];
    this.product = props['product'];
    this.serialNumber = props['serialNumber'];
    this.version = props['version'];
    this.ports = (props['ports'] as List).map((p) => new PortInfo(p)).toList();
  }

  toJson() {
    return {
      'id': id,
      'inputPortCount': inputPortCount,
      'outputPortCount': outputPortCount,
      'type': type,
      'manufacturer': manufacturer,
      'name': name,
      'product': product,
      'serialNumber': serialNumber,
      'version': version,
      'ports': ports,
    };
  }
}
