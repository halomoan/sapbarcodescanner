import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._ctor();
  DeviceInfoPlugin _deviceInfo;
  SharedPreferences _prefs;
  final String _configServer = 'configServer';
  final String _uniqueID = 'uniqueID';

  factory Preferences() {
    return _instance;
  }

  Preferences._ctor();

  init() async {
    this._prefs = await SharedPreferences.getInstance();
    this._deviceInfo = new DeviceInfoPlugin();
    this._setUniqueID();
  }

  void _setUniqueID() {
    String uniqueID = _prefs.getString(_uniqueID);
    if (uniqueID == null) {}
  }

  get configServer {
    return _prefs.getString(_configServer) ?? '';
  }

  set configServer(String value) {
    _prefs.setString(_configServer, value);
  }

  get uniqueID {
    return _prefs.getString(_uniqueID) ?? '';
  }

  Future<String> _getId() async {
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
}
