package com.synthfeeder.midi;

import android.content.Context;
import android.media.midi.*;
import android.util.SparseArray;

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

  public static final String METHOD_CHANNEL_NAME = "com.synthfeeder/midi";
  public static final String DEVICE_CHANNEL_NAME = "com.synthfeeder/midi/devices";
  public static final String MESSAGE_CHANNEL_NAME = "com.synthfeeder/midi/messages";
  MidiManager midi;

  MethodChannel methodChannel;
  EventChannel deviceEventChannel;
  EventChannel midiDataChannel;

  HashMap<Integer, MidiDeviceInfo> deviceInfo = new HashMap();

  HashMap<Integer, MidiDevice> activeDevices = new HashMap();

  SparseArray<MidiOutputPort> activeOutputPorts = new SparseArray<>();
  int nextOutputPortIndex = 0;

  SparseArray<MidiInputPort> activeInputPorts = new SparseArray<>();
  int nextInputPortIndex = 0;

  MidiManager.DeviceCallback deviceCallback;

  boolean sendMidiData = false;
  EventChannel.EventSink midiDataSink;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {

    final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL_NAME);
    final EventChannel deviceEventChannel = new EventChannel(registrar.messenger(), DEVICE_CHANNEL_NAME);
    final EventChannel messageEventChannel = new EventChannel(registrar.messenger(), MESSAGE_CHANNEL_NAME);
    MidiManager midi = (MidiManager) registrar.context().getSystemService(Context.MIDI_SERVICE);
    final MidiPlugin plugin = new MidiPlugin(midi, methodChannel, deviceEventChannel, messageEventChannel);

  }

  MidiPlugin(MidiManager midi, MethodChannel methodChannel, EventChannel deviceChannel, EventChannel messageChannel) {
    this.midi = midi;
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
    else if (call.method.equals("openOutputPort")) {
      int deviceId = (Integer) ((Map)call.arguments).get("deviceId");
      int portNumber = (Integer) ((Map)call.arguments).get("port");
      MidiOutputPort port = this.activeDevices.get(deviceId).openOutputPort(portNumber);
      activeOutputPorts.append(nextOutputPortIndex, port);
      result.success(nextOutputPortIndex);
      port.connect(new FlutterMidiReceiver(nextOutputPortIndex) {
        @Override
        public void onSend(byte[] message, int offset, int count, long timestamp) throws IOException {
          if (sendMidiData && midiDataSink != null) {
            byte[] trimmed = new byte[count];
            System.arraycopy(message, offset, trimmed, 0, count);
            HashMap toReturn = new HashMap();
            toReturn.put("port", this.portId);
            toReturn.put("data", trimmed);
            midiDataSink.success(toReturn);
          }
        }
      });
      nextOutputPortIndex++;
    }
    else if (call.method.equals("openInputPort")) {
      int deviceId = (Integer) ((Map)call.arguments).get("deviceId");
      int portNumber = (Integer) ((Map)call.arguments).get("port");
      MidiInputPort port = this.activeDevices.get(deviceId).openInputPort(portNumber);
      activeInputPorts.append(nextInputPortIndex, port);
      result.success(nextInputPortIndex);
    }
    else if (call.method.equals("send")) {
      int portNumber = (Integer) ((Map)call.arguments).get("port");
      byte[] data = (byte[]) ((Map)call.arguments).get("data");
      MidiInputPort port = this.activeInputPorts.get(portNumber);
      try {
        port.send(data, 0, data.length);
        result.success(null);
      }
      catch(IOException e) {
        result.error(e.toString(), e.getMessage(), e.getMessage());
      }
    }
    else {
      result.notImplemented();
    }
  }

  abstract class FlutterMidiReceiver extends MidiReceiver {
    int portId;
    FlutterMidiReceiver(int portId) {
      this.portId = portId;
    }
  }


  private List listDevices() {
    MidiDeviceInfo[] devices = this.midi.getDevices();
    this.deviceInfo.clear();
    ArrayList<Map> list = new ArrayList();
    for (MidiDeviceInfo dev : devices) {
      this.deviceInfo.put(dev.getId(), dev);
      list.add(DeviceInfoMapper.readDevice(dev));
    }
    return list;
  }


  @Override
  public void onListen(Object o, final EventChannel.EventSink eventSink) {
    this.deviceCallback = new MidiManager.DeviceCallback() {
      @Override
      public void onDeviceAdded(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_ADDED");
        event.put("device", DeviceInfoMapper.readDevice(device));
        eventSink.success(event);
      }

      @Override
      public void onDeviceRemoved(MidiDeviceInfo device) {
        HashMap event = new HashMap();
        event.put("type", "DEVICE_REMOVED");
        event.put("device", DeviceInfoMapper.readDevice(device));
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
