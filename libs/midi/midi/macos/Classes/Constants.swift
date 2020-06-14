//
//  Constants.swift
//  midi
//
//  Created by Michael Marner on 21/9/19.
//

import Foundation
import FlutterMacOS

public class Constants {
  public static var METHOD_CHANNEL_NAME = "com.synthfeeder/midi";
  public static var DEVICE_CHANNEL_NAME = "com.synthfeeder/midi/devices";
  public static var MESSAGE_CHANNEL_NAME = "com.synthfeeder/midi/messages";
  
  
  public static var GET_INPUTS = "getInputs";
  public static var GET_OUTPUTS = "getOutputs";
  
  public static var OPEN_INPUT = "openInput";
  public static var OPEN_OUTPUT = "openOutput";
  
  public static var CLOSE_INPUT = "closeInput";
  public static var CLOSE_OUTPUT = "closeOutput";
  
  public static var SEND = "send";
  
  public static var ID = "id";
  public static var MANUFACTURER = "manufacturer";
  public static var NAME = "name";
  public static var VERSION = "version";
  
  
  public static var ERR_NOT_OPEN = "404";
  public static var ERR_IO = "500";
  
  
  public static var PORT = "port";
  public static var DATA = "data";
  
  public static var INPUT = "i";
  public static var OUTPUT = "o";
  public static var NUMBER = "number";
  
  public static var TYPE = "type";
  
  public static var STATE = "state";
  public static var CONNECTED = "connected";
  public static var DISCONNECTED = "disconnected";
}


