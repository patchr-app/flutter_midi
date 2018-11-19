package com.synthfeeder.midi;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import android.media.midi.*;
import android.os.Bundle;

public class DeviceInfoMapper {

  public static Map readDevice(MidiDeviceInfo dev) {
    MidiDeviceInfo.PortInfo[] ports = dev.getPorts();
    ArrayList<Map> portMap = new ArrayList();
    for (MidiDeviceInfo.PortInfo port : ports) {
      portMap.add(DeviceInfoMapper.mapPortInfo(port));
    }
    Map deviceInfo = DeviceInfoMapper.mapDeviceInfo(dev);
    deviceInfo.put("ports", portMap);
    return deviceInfo;
  }

  public static Map mapDeviceInfo(MidiDeviceInfo i) {
    Bundle properties = i.getProperties();
    HashMap map = new HashMap();
    map.put("id", i.getId());
    map.put("inputPortCount", i.getInputPortCount());
    map.put("outputPortCount", i.getOutputPortCount());
    switch (i.getType()) {
      case MidiDeviceInfo.TYPE_USB:
        map.put("type", "USB");
        break;
      case MidiDeviceInfo.TYPE_BLUETOOTH:
        map.put("type", "BLUETOOTH");
        break;
      case MidiDeviceInfo.TYPE_VIRTUAL:
        map.put("type", "VIRTUAL");
        break;
    }
    map.put("manufacturer", properties.getString(MidiDeviceInfo.PROPERTY_MANUFACTURER));
    map.put("name", properties.getString(MidiDeviceInfo.PROPERTY_NAME));
    map.put("product", properties.getString(MidiDeviceInfo.PROPERTY_PRODUCT));
    map.put("serialNumber", properties.getString(MidiDeviceInfo.PROPERTY_SERIAL_NUMBER));
    map.put("version", properties.getString(MidiDeviceInfo.PROPERTY_VERSION));
    return map;
  }

  public static Map mapPortInfo(MidiDeviceInfo.PortInfo p) {
    HashMap map = new HashMap();
    map.put("name", p.getName());
    map.put("number", p.getPortNumber());
    switch (p.getType()) {
      case MidiDeviceInfo.PortInfo.TYPE_INPUT:
        map.put("type", "INPUT");
        break;
      case MidiDeviceInfo.PortInfo.TYPE_OUTPUT:
        map.put("type", "OUTPUT");
        break;
    }
    return map;
  }
}
