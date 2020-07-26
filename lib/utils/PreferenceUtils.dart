import 'dart:io';
import 'dart:async' show Future;
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static SharedPreferences _prefs;
  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();
  static DeviceInfoPlugin _deviceInfo;

  static Future<SharedPreferences> init() async {
    _prefs = await _instance;
    await _setUniqueID();
    return _prefs;
  }

  static Future<void> _setUniqueID() async {
    _deviceInfo = new DeviceInfoPlugin();
    String uniqueID = _prefs.getString('uniqueID');
    if (uniqueID == null) {
      uniqueID = await _getId();
      _prefs.setString('uniqueID', uniqueID);
    }
  }

  static Future<String> _getId() async {
    String identifier;
    try {
      if (Platform.isAndroid) {
        var build = await _deviceInfo.androidInfo;
        // var build = await deviceInfoPlugin.androidInfo;
        // deviceName = build.model;
        // deviceVersion = build.version.toString();
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await _deviceInfo.iosInfo;
        // deviceName = data.name;
        // deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    return identifier;
  }

  // Configuration Server
  static get configServer {
    return _prefs.getString('configServer') ?? '';
  }

  static set configServer(String value) {
    _prefs.setString('configServer', value);
  }

  static get configUserID {
    return _prefs.getString('configUserID') ?? '';
  }

  static set configUserID(String value) {
    _prefs.setString('configUserID', value);
  }

  static get configPasswd {
    return _prefs.getString('configPasswd') ?? '';
  }

  static set configPasswd(String value) {
    _prefs.setString('configPasswd', value);
  }

  // Update Server
  static get updServer {
    return _prefs.getString('updServer') ?? '';
  }

  static set updServer(String value) {
    _prefs.setString('updServer', value);
  }

  static get updUserID {
    return _prefs.getString('updUserID') ?? '';
  }

  static set updUserID(String value) {
    _prefs.setString('updUserID', value);
  }

  static get updPasswd {
    return _prefs.getString('updPasswd') ?? '';
  }

  static set updPasswd(String value) {
    _prefs.setString('updPasswd', value);
  }

  // Unique ID
  static get uniqueID {
    return _prefs.getString('uniqueID') ?? '';
  }

  // Barcode Format
  static get coCodeLen {
    return _prefs.getInt('coCodeLen') ?? 0;
  }

  static set coCodeLen(int value) {
    _prefs.setInt('coCodeLen', value);
  }

  static get mainCodeLen {
    return _prefs.getInt('mainCodeLen') ?? 0;
  }

  static set mainCodeLen(int value) {
    _prefs.setInt('mainCodeLen', value);
  }

  static get subCodeLen {
    return _prefs.getInt('subCodeLen') ?? 0;
  }

  static set subCodeLen(int value) {
    _prefs.setInt('subCodeLen', value);
  }

  static get counterLen {
    return _prefs.getInt('counterLen') ?? 0;
  }

  static set counterLen(int value) {
    _prefs.setInt('counterLen', value);
  }
}
