package com.synthfeeder.midi;

import android.content.Context;
import android.media.midi.*;
import android.os.Bundle;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** MidiPlugin */
public class MidiPlugin implements MethodCallHandler, EventChannel.StreamHandler {

  private MidiManager midi;

  private EventChannel deviceEventChannel;

  private HashMap<Integer, MidiDeviceInfo> deviceInfo = new HashMap();

  private HashMap<Integer, MidiDevice> activeDevices = new HashMap();

  MidiManager.DeviceCallback deviceCallback;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final String channelName = "com.synthfeeder/midi";
    final String deviceChannelName = "com.synthfeeder/midi/devices";

    final MethodChannel channel = new MethodChannel(registrar.messenger(), channelName);
    final MidiPlugin plugin = new MidiPlugin();
    plugin.midi = (MidiManager) registrar.context().getSystemService(Context.MIDI_SERVICE);
    channel.setMethodCallHandler(plugin);

    final EventChannel deviceEventChannel = new EventChannel(registrar.messenger(), deviceChannelName);
    deviceEventChannel.setStreamHandler(plugin);

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("listDevices")) {
      result.success(this.listDevices());
    } else if (call.method.equals("openDevice")) {
      final int id = (Integer) call.arguments;
      final Result r = result;
      this.midi.openDevice(this.deviceInfo.get(id), new MidiManager.OnDeviceOpenedListener() {
        public void onDeviceOpened(MidiDevice dev) {
          activeDevices.put(id, dev);
          r.success(id);
        }
      }, null);
    } else if (call.method.equals("closeDevice")) {
      try {
        this.activeDevices.get(call.arguments).close();
        result.success(call.arguments);
      } catch (IOException e) {
        result.error(e.getClass().getName(), e.toString(), null);
      }
    }

    else {
      result.notImplemented();
    }
  }

  private List listDevices() {
    MidiDeviceInfo[] devices = this.midi.getDevices();
    this.deviceInfo.clear();
    ArrayList<Map> list = new ArrayList();
    for (MidiDeviceInfo dev : devices) {
      list.add(this.readDevice(dev));
    }
    return list;
  }

  private Map readDevice(MidiDeviceInfo dev) {
    MidiDeviceInfo.PortInfo[] ports = dev.getPorts();
    ArrayList<Map> portMap = new ArrayList();
    for (MidiDeviceInfo.PortInfo port : ports) {
      portMap.add(this.mapPortInfo(port));
    }
    Map deviceInfo = this.mapDeviceInfo(dev);
    deviceInfo.put("ports", portMap);
    return deviceInfo;
  }

  private Map mapPortInfo(MidiDeviceInfo.PortInfo p) {
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

  private Map mapDeviceInfo(MidiDeviceInfo i) {
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

  @Override
  public void onListen(Object o, final EventChannel.EventSink eventSink) {
    this.deviceCallback = new MidiManager.DeviceCallback() {
      @Override
      public void onDeviceAdded(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_ADDED");
        event.put("device", readDevice(device));
        eventSink.success(event);
      }

      @Override
      public void onDeviceRemoved(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_REMOVED");
        event.put("device", readDevice(device));
        eventSink.success(event);
      }
    };

    this.midi.registerDeviceCallback(this.deviceCallback, null);
  }

  @Override
  public void onCancel(Object o) {
    this.midi.unregisterDeviceCallback(this.deviceCallback);
  }
}
