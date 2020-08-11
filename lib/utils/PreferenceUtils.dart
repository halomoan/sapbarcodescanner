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
  static get serverUrl {
    return _prefs.getString('serverUrl') ?? '';
  }

  static set serverUrl(String value) {
    _prefs.setString('serverUrl', value);
  }

  static get serverPasswd {
    return _prefs.getString('serverPasswd') ?? '';
  }

  static set serverPasswd(String value) {
    _prefs.setString('serverPasswd', value);
  }

  // Unique ID
  static get uniqueID {
    return _prefs.getString('uniqueID') ?? '';
  }

  static get accessToken {
    return _prefs.getString('accessToken') ?? '';
  }

  static set accessToken(String value) {
    _prefs.setString('accessToken', value);
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

  static get lastUpdate {
    return _prefs.getInt('lastUpdate') ?? 0;
  }

  static set lastUpdate(int value) {
    _prefs.setInt('lastUpdate', value);
  }
}
