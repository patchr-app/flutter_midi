package app.patchr.midi_io

import android.content.Context
import android.media.midi.*
import android.media.midi.MidiManager.DeviceCallback
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException


/** MidiIoPlugin */
class MidiIoPlugin: FlutterPlugin, MethodCallHandler,  EventChannel.StreamHandler {

  private lateinit var midi: MidiManager

  private lateinit var methodChannel: MethodChannel
  private lateinit var deviceEventChannel: EventChannel
  private lateinit var midiDataChannel: EventChannel

  var sendMidiData = false
  var midiDataSink: EventSink? = null
  var deviceCallback: DeviceCallback? = null

  var connectedDevices = HashMap<Int, MidiDeviceInfo>()
  var activeDevices: HashMap<Int, MidiDevice> = HashMap<Int, MidiDevice>()
  var activeDestinations = HashMap<String, MidiInputPort>()
  var activeSources = HashMap<String, MidiOutputPort>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    midi = flutterPluginBinding.applicationContext.getSystemService(Context.MIDI_SERVICE) as MidiManager;

    for (d in midi.devices) {
      connectedDevices[d.id] = d
    }

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, Constants.METHOD_CHANNEL_NAME)
    methodChannel.setMethodCallHandler(this)
    deviceEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, Constants.DEVICE_CHANNEL_NAME)
    deviceEventChannel.setStreamHandler(this)
    midiDataChannel = EventChannel(flutterPluginBinding.binaryMessenger, Constants.MESSAGE_CHANNEL_NAME)
    midiDataChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(o: Any, eventSink: EventSink) {
        midiDataSink = eventSink
        sendMidiData = true
      }

      override fun onCancel(o: Any) {
        sendMidiData = false
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when {
      call.method.equals(Constants.GET_DESTINATIONS) -> {
        this.getDestinations(call, result);
      }
      call.method.equals(Constants.GET_SOURCES) -> {
        this.getSources(call, result);
      }
      call.method.equals(Constants.OPEN_DESTINATION) -> {
        this.openDestination(call, result);
      }
      call.method.equals(Constants.OPEN_SOURCE) -> {
        this.openSource(call, result);
      }
      call.method.equals(Constants.CLOSE_DESTINATION) -> {
        this.closeDestination(call, result);
      }
      call.method.equals(Constants.CLOSE_SOURCE) -> {
        this.closeSource(call, result);
      }
      call.method.equals(Constants.SEND) -> {
        this.send(call, result);
      }
      else -> {
        result.notImplemented();
      }
    }
  }

  private fun getDestinations(call: MethodCall, result: Result) {
    val devices = midi.devices
    val portList: ArrayList<Map<*, *>> = ArrayList()
    for (d in devices) {
      connectedDevices.clear()
      connectedDevices[d.id] = d
      for (p in d.ports) {
        if (p.type == MidiDeviceInfo.PortInfo.TYPE_INPUT) {
          portList.add(buildPortInfoMap(d, p))
        }
      }
    }
    result.success(portList)
  }

  private fun getSources(call: MethodCall, result: Result) {
    val devices = midi.devices
    val portList: ArrayList<Map<*, *>> = ArrayList()
    for (d in devices) {
      for (p in d.ports) {
        if (p.type == MidiDeviceInfo.PortInfo.TYPE_OUTPUT) {
          portList.add(buildPortInfoMap(d, p))
        }
      }
    }
    result.success(portList)
  }


  private fun openDestination(call: MethodCall, result: Result) {
    val id = call.arguments as String
    val deviceId: Int = this.getDeviceId(id)
    val portId: Int = this.getPortId(id)
    // already connected, do nothing
    if (activeDestinations.containsKey(id)) {
      result.success(id)
    } else {
      if (activeDevices.containsKey(deviceId)) {
        val p = activeDevices[deviceId]!!.openInputPort(portId)
        activeDestinations[id] = p
        result.success(id)
      } else {
        midi.openDevice(connectedDevices[deviceId], { device ->
          activeDevices[deviceId] = device
          val p = device.openInputPort(portId)
          activeDestinations[id] = p
          val wrapper = MethodResultWrapper(result)
          wrapper.success(id)
        }, null)
      }
    }
  }


  private fun openSource(call: MethodCall, result: Result) {
    val id = call.arguments as String
    val deviceId: Int = this.getDeviceId(id)
    val portId: Int = this.getPortId(id)
    // already connected, do nothing
    if (activeSources.containsKey(id)) {
      result.success(id)
    } else {
      val wrapper = EventSinkWrapper(midiDataSink as EventSink)
      if (activeDevices.containsKey(deviceId)) {
        val p = activeDevices[deviceId]!!.openOutputPort(portId)
        p.connect(object : FlutterMidiReceiver(id) {
          @Throws(IOException::class)
          override fun onSend(message: ByteArray?, offset: Int, count: Int, timestamp: Long) {
            if (sendMidiData && midiDataSink != null) {
              val trimmed = ByteArray(count)
              System.arraycopy(message, offset, trimmed, 0, count)
              val toReturn = HashMap<Any, Any>()
              toReturn[Constants.PORT] = id
              toReturn[Constants.DATA] = trimmed
              wrapper.success(toReturn)
            }
          }
        })
        activeSources[id] = p
        result.success(id)
      } else {
        midi.openDevice(connectedDevices[deviceId], { device ->
          activeDevices[deviceId] = device
          val p = device.openOutputPort(portId)
          p.connect(object : FlutterMidiReceiver(id) {
            @Throws(IOException::class)
            override fun onSend(message: ByteArray?, offset: Int, count: Int, timestamp: Long) {
              if (sendMidiData && midiDataSink != null) {
                val trimmed = ByteArray(count)
                System.arraycopy(message, offset, trimmed, 0, count)
                val toReturn = HashMap<Any, Any>()
                toReturn[Constants.PORT] = id
                toReturn[Constants.DATA] = trimmed
                wrapper.success(toReturn)
              }
            }
          })
          activeSources[id] = p
          result.success(id)
        }, null)
      }
    }
  }


  private fun closeSource(call: MethodCall, result: Result) {
    val id = call.arguments as String
    val port = activeSources[id]
    try {
      if (port != null) {
        port.close()
        activeSources.remove(id)
        result.success(id)
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Output Port $id not open", null)
      }
    } catch (e: IOException) {
      result.error(Constants.ERR_IO, "Output Port $id could not be closed", e)
    }
  }

  private fun closeDestination(call: MethodCall, result: Result) {
    val id = call.arguments as String
    val port = activeDestinations[id]
    try {
      if (port != null) {
        port.close()
        activeDestinations.remove(id)
        result.success(id)
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Input Port $id not open", null)
      }
    } catch (e: IOException) {
      result.error(Constants.ERR_IO, "Input Port $id could not be closed", e)
    }
  }


  private fun send(call: MethodCall, result: Result) {
    val id = (call.arguments as Map<String?, *>)[Constants.PORT] as String?
    val port = activeDestinations[id]
    try {
      if (port != null) {
        val data = (call.arguments as Map<String?, *>)[Constants.DATA] as ByteArray?
        port.send(data, 0, data!!.size)
      } else {
        result.error(Constants.ERR_NOT_OPEN, "Input Port $id not open", null)
      }
    } catch (e: IOException) {
      result.error(Constants.ERR_IO, "Could not write to port $id", e)
    }
  }

  private fun getDeviceId(id: String): Int {
    return id.substring(2, id.indexOf(':', 2)).toInt()
  }

  private fun getPortId(id: String): Int {
    return id.substring(id.indexOf(':', 2) + 1).toInt()
  }


  /**
   * Constructs an ID to represent the device and port combo.
   *
   *
   * Prefixed with i for input, o for output.
   *
   *
   * Eg: i:12:0
   *
   *
   * for Input 0 of Device 12
   *
   * @param d
   * @param p
   * @return
   */
  private fun buildId(d: MidiDeviceInfo, p: MidiDeviceInfo.PortInfo): String {
    return ((if (p.type == MidiDeviceInfo.PortInfo.TYPE_INPUT) Constants.DESTINATION else Constants.SOURCE) + ":" + d.id
            + ":" + p.portNumber)
  }

  fun buildPortInfoMap(d: MidiDeviceInfo, p: MidiDeviceInfo.PortInfo): Map<String, *> {
    val m = HashMap<String, Any>()
    val deviceProps = d.properties
    m[Constants.ID] = buildId(d, p)
    m[Constants.MANUFACTURER] = deviceProps.getString(MidiDeviceInfo.PROPERTY_MANUFACTURER) as String
    m[Constants.VERSION] = deviceProps.getString(MidiDeviceInfo.PROPERTY_VERSION) as String
    m[Constants.NUMBER] = p.portNumber
    m[Constants.TYPE] = if (p.type == MidiDeviceInfo.PortInfo.TYPE_INPUT) Constants.DESTINATION else Constants.SOURCE
    m[Constants.NAME] = if (p.name.length > 0) p.name else deviceProps.getString(MidiDeviceInfo.PROPERTY_PRODUCT) + " " + p.portNumber
    return m
  }


  override fun onListen(o: Any?, eventSink: EventSink?) {
    deviceCallback = object : DeviceCallback() {
      var wrapper: EventSinkWrapper = EventSinkWrapper(eventSink as EventSink)
      override fun onDeviceAdded(device: MidiDeviceInfo) {
        connectedDevices[device.id] = device
        for (p in device.ports) {
          val portInfo: Map<String, *> = buildPortInfoMap(device, p!!)
          val event = HashMap<Any, Any>()
          event[Constants.ID] = buildId(device, p)
          event[Constants.STATE] = Constants.CONNECTED
          event[Constants.PORT] = portInfo
          wrapper.success(event)
        }
      }

      override fun onDeviceRemoved(device: MidiDeviceInfo) {
        connectedDevices.remove(device.id)
        for (p in device.ports) {
          val portInfo: Map<*, *> = buildPortInfoMap(device, p!!)
          val event = HashMap<Any, Any>()
          event[Constants.ID] = buildId(device, p)
          event[Constants.STATE] = Constants.DISCONNECTED
          event[Constants.PORT] = portInfo
          wrapper.success(event)
        }
      }
    }
    midi.registerDeviceCallback(deviceCallback, null)
  }


  override fun onCancel(o: Any?) {
    midi.unregisterDeviceCallback(deviceCallback)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }


  inner class EventSinkWrapper : EventSink {

    lateinit var rawSink: EventSink
    private lateinit var handler: Handler;

    constructor(sink: EventSink) {
      rawSink = sink;
      handler = Handler(Looper.getMainLooper());
    }


    override fun success(event: Any) {
      handler.post {
        rawSink.success(event);
      }

    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
      handler.post { rawSink.error(errorCode, errorMessage, errorDetails); };
    }


    override fun endOfStream() {
      handler.post { rawSink.endOfStream(); }
    };
  }


  // MethodChannel.Result wrapper that responds on the platform thread.
  inner class MethodResultWrapper : Result {
    lateinit var methodResult: Result;
    lateinit var handler: Handler;

    constructor(result: Result) {
      methodResult = result;
      handler = Handler(Looper.getMainLooper());
    }

    override fun success(result: Any?) {
      handler.post { methodResult.success(result); };
    }


    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
      handler.post { methodResult.error(errorCode, errorMessage, errorDetails); };
    }


    override fun notImplemented() {
      handler.post { methodResult.notImplemented(); };
    }
  }

}