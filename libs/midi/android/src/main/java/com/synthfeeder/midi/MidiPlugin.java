package com.synthfeeder.midi;

import android.content.Context;
import android.media.midi.MidiDevice;
import android.media.midi.MidiDeviceInfo;
import android.media.midi.MidiInputPort;
import android.media.midi.MidiManager;
import android.media.midi.MidiOutputPort;
import android.os.Bundle;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * MidiPlugin
 */
public class MidiPlugin implements MethodCallHandler, EventChannel.StreamHandler {

  MidiPlugin(MidiManager midi, MethodChannel methodChannel, EventChannel deviceChannel, EventChannel messageChannel) {
    this.midi = midi;
    for (MidiDeviceInfo d : this.midi.getDevices()) {
      this.connectedDevices.put(d.getId(), d);
    }

    this.methodChannel = methodChannel;
    methodChannel.setMethodCallHandler(this);
    this.deviceEventChannel = deviceChannel;
    deviceEventChannel.setStreamHandler(this);
    this.midiDataChannel = messageChannel;
    this.midiDataChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {
        midiDataSink = eventSink;
        sendMidiData = true;
      }

      @Override
      public void onCancel(Object o) {
        sendMidiData = false;
      }
    });
  }

  MidiManager midi;

  MethodChannel methodChannel;
  EventChannel deviceEventChannel;
  EventChannel midiDataChannel;

  boolean sendMidiData = false;
  EventChannel.EventSink midiDataSink;
  MidiManager.DeviceCallback deviceCallback;

  HashMap<Integer, MidiDeviceInfo> connectedDevices = new HashMap<Integer, MidiDeviceInfo>();
  HashMap<Integer, MidiDevice> activeDevices = new HashMap<Integer, MidiDevice>();
  HashMap<String, MidiInputPort> activeInputs = new HashMap<String, MidiInputPort>();
  HashMap<String, MidiOutputPort> activeOutputs = new HashMap<String, MidiOutputPort>();

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), Constants.METHOD_CHANNEL_NAME);
    final EventChannel deviceEventChannel = new EventChannel(registrar.messenger(), Constants.DEVICE_CHANNEL_NAME);
    final EventChannel messageEventChannel = new EventChannel(registrar.messenger(), Constants.MESSAGE_CHANNEL_NAME);
    MidiManager midi = (MidiManager) registrar.context().getSystemService(Context.MIDI_SERVICE);
    final MidiPlugin plugin = new MidiPlugin(midi, methodChannel, deviceEventChannel, messageEventChannel);

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals(Constants.GET_INPUTS)) {
      this.getInputs(call, result);
    } else if (call.method.equals(Constants.GET_OUTPUTS)) {
      this.getOutputs(call, result);
    } else if (call.method.equals(Constants.OPEN_INPUT)) {
      this.openInput(call, result);
    } else if (call.method.equals(Constants.OPEN_OUTPUT)) {
      this.openOutput(call, result);
    } else if (call.method.equals(Constants.CLOSE_INPUT)) {
      this.closeInput(call, result);
    } else if (call.method.equals(Constants.CLOSE_OUTPUT)) {
      this.closeOutput(call, result);
    } else if (call.method.equals(Constants.SEND)) {
      this.send(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void getInputs(MethodCall call, Result result) {
    MidiDeviceInfo[] devices = this.midi.getDevices();
    ArrayList<Map> portList = new ArrayList();
    for (MidiDeviceInfo d : devices) {
      connectedDevices.clear();
      connectedDevices.put(d.getId(), d);
      for (MidiDeviceInfo.PortInfo p : d.getPorts()) {
        if (p.getType() == MidiDeviceInfo.PortInfo.TYPE_INPUT) {
          portList.add(buildPortInfoMap(d, p));
        }
      }
    }
    result.success(portList);
  }

  private void getOutputs(MethodCall call, Result result) {
    MidiDeviceInfo[] devices = this.midi.getDevices();
    ArrayList<Map> portList = new ArrayList();
    for (MidiDeviceInfo d : devices) {
      for (MidiDeviceInfo.PortInfo p : d.getPorts()) {
        if (p.getType() == MidiDeviceInfo.PortInfo.TYPE_OUTPUT) {
          portList.add(buildPortInfoMap(d, p));
        }
      }
    }
    result.success(portList);
  }

  private void openInput(MethodCall call, final Result result) {
    final String id = (String) call.arguments;
    final int deviceId = this.getDeviceId(id);
    final int portId = this.getPortId(id);
    // already connected, do nothing
    if (activeInputs.containsKey(id)) {
      result.success(id);
    } else {
      if (activeDevices.containsKey(deviceId)) {
        MidiInputPort p = activeDevices.get(deviceId).openInputPort(portId);
        this.activeInputs.put(id, p);
        result.success(id);
      } else {
        this.midi.openDevice(this.connectedDevices.get(deviceId), new MidiManager.OnDeviceOpenedListener() {
          @Override
          public void onDeviceOpened(MidiDevice device) {
            activeDevices.put(deviceId, device);
            MidiInputPort p = device.openInputPort(portId);
            activeInputs.put(id, p);
            result.success(id);
          }
        }, null);
      }
    }
  }

  private void openOutput(MethodCall call, final Result result) {
    final String id = (String) call.arguments;
    final int deviceId = this.getDeviceId(id);
    final int portId = this.getPortId(id);
    // already connected, do nothing
    if (activeOutputs.containsKey(id)) {
      result.success(id);
    } else {
      if (activeDevices.containsKey(deviceId)) {
        MidiOutputPort p = activeDevices.get(deviceId).openOutputPort(portId);
        p.connect(new FlutterMidiReceiver(id) {
          @Override
          public void onSend(byte[] message, int offset, int count, long timestamp) throws IOException {
            if (sendMidiData && midiDataSink != null) {
              byte[] trimmed = new byte[count];
              System.arraycopy(message, offset, trimmed, 0, count);
              HashMap toReturn = new HashMap();
              toReturn.put(Constants.PORT, this.id);
              toReturn.put(Constants.DATA, trimmed);
              midiDataSink.success(toReturn);
            }
          }
        });
        this.activeOutputs.put(id, p);
        result.success(id);
      } else {
        this.midi.openDevice(this.connectedDevices.get(deviceId), new MidiManager.OnDeviceOpenedListener() {
          @Override
          public void onDeviceOpened(MidiDevice device) {
            activeDevices.put(deviceId, device);
            MidiOutputPort p = device.openOutputPort(portId);
            p.connect(new FlutterMidiReceiver(id) {
              @Override
              public void onSend(byte[] message, int offset, int count, long timestamp) throws IOException {
                if (sendMidiData && midiDataSink != null) {
                  byte[] trimmed = new byte[count];
                  System.arraycopy(message, offset, trimmed, 0, count);
                  HashMap toReturn = new HashMap();
                  toReturn.put(Constants.PORT, this.id);
                  toReturn.put(Constants.DATA, trimmed);
                  midiDataSink.success(toReturn);
                }
              }
            });
            activeOutputs.put(id, p);
            result.success(id);
          }
        }, null);
      }
    }
  }

  private void closeOutput(MethodCall call, final Result result) {
    final String id = (String) call.arguments;
    MidiOutputPort port = activeOutputs.get(id);
    try {

      if (port != null) {
        port.close();
        activeOutputs.remove(id);
        result.success(id);
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Output Port " + id + " not open", null);
      }
    } catch (IOException e) {
      result.error(Constants.ERR_IO, "Output Port " + id + " could not be closed", e);
    }
  }

  private void closeInput(MethodCall call, final Result result) {
    final String id = (String) call.arguments;
    MidiInputPort port = activeInputs.get(id);
    try {

      if (port != null) {
        port.close();
        activeInputs.remove(id);
        result.success(id);
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Input Port " + id + " not open", null);
      }
    } catch (IOException e) {
      result.error(Constants.ERR_IO, "Input Port " + id + " could not be closed", e);
    }
  }

  private void send(MethodCall call, final Result result) {
    final String id = (String) ((Map<String, ?>) call.arguments).get(Constants.PORT);
    MidiInputPort port = activeInputs.get(id);
    try {
      if (port != null) {
        byte[] data = (byte[]) ((Map<String, ?>) call.arguments).get(Constants.DATA);
        port.send(data, 0, data.length);
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Input Port " + id + " not open", null);
      }
    } catch (IOException e) {
      result.error(Constants.ERR_IO, "Could not write to port " + id, e);
    }
  }

  private int getDeviceId(String id) {
    return Integer.parseInt(id.substring(2, id.indexOf(':', 2)));
  }

  private int getPortId(String id) {
    return Integer.parseInt(id.substring(id.indexOf(':', 2) + 1));
  }

  /**
   * Constructs an ID to represent the device and port combo.
   *
   * Prefixed with i for input, o for output.
   *
   * Eg: i:12:0
   *
   * for Input 0 of Device 12
   *
   * @param d
   * @param p
   * @return
   */
  private String buildId(MidiDeviceInfo d, MidiDeviceInfo.PortInfo p) {
    return (p.getType() == MidiDeviceInfo.PortInfo.TYPE_INPUT ? Constants.INPUT : Constants.OUTPUT) + ":" + d.getId()
        + ":" + p.getPortNumber();
  }

  Map<String, ?> buildPortInfoMap(MidiDeviceInfo d, MidiDeviceInfo.PortInfo p) {
    HashMap m = new HashMap();
    Bundle deviceProps = d.getProperties();
    m.put(Constants.ID, buildId(d, p));
    m.put(Constants.MANUFACTURER, deviceProps.getString(MidiDeviceInfo.PROPERTY_MANUFACTURER));
    m.put(Constants.VERSION, deviceProps.getString(MidiDeviceInfo.PROPERTY_VERSION));
    m.put(Constants.NUMBER, p.getPortNumber());
    m.put(Constants.NAME, p.getName().length() > 0 ? p.getName()
        : deviceProps.getString(MidiDeviceInfo.PROPERTY_PRODUCT) + " " + p.getPortNumber());

    return m;
  }

  @Override
  public void onListen(Object o, final EventChannel.EventSink eventSink) {
    this.deviceCallback = new MidiManager.DeviceCallback() {
      @Override
      public void onDeviceAdded(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_ADDED");
        // event.put("device", DeviceInfoMapper.readDevice(device));
        eventSink.success(event);
      }

      @Override
      public void onDeviceRemoved(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_REMOVED");
        // event.put("device", DeviceInfoMapper.readDevice(device));
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
