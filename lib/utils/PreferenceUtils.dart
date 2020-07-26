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

  static get configServer {
    return _prefs.getString('configServer') ?? '';
  }

  static set configServer(String value) {
    _prefs.setString('configServer', value);
  }

  static get uniqueID {
    return _prefs.getString('uniqueID') ?? '';
  }
}
