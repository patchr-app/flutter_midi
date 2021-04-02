//
//  Constants.swift
//  midi
//
//  Created by Michael Marner on 21/9/19.
//

import Foundation
import FlutterMacOS

public class Constants {
  public static var METHOD_CHANNEL_NAME = "app.patchr/midi";
  public static var DEVICE_CHANNEL_NAME = "app.patchr/midi/devices";
  public static var MESSAGE_CHANNEL_NAME = "app.patchr/midi/messages";
  
  
  
  public static var GET_DESTINATIONS = "getDestinations";
  public static var GET_SOURCES = "getSources";

  public static var OPEN_DESTINATION = "openDestination";
  public static var OPEN_SOURCE = "openSource";

  public static var CLOSE_DESTINATION = "closeDestination";
  public static var CLOSE_SOURCE = "closeSource";
  
  public static var SEND = "send";
  
  public static var ID = "id";
  public static var MANUFACTURER = "manufacturer";
  public static var NAME = "name";
  public static var VERSION = "version";
  
  
  public static var ERR_NOT_OPEN = "404";
  public static var ERR_IO = "500";
  
  
  public static var PORT = "port";
  public static var DATA = "data";
  
  public static var DESTINATION = "d";
  public static var SOURCE = "s";
  public static var NUMBER = "number";
  
  public static var TYPE = "type";
  
  public static var STATE = "state";
  public static var CONNECTED = "connected";
  public static var DISCONNECTED = "disconnected";
}


