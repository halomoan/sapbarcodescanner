import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = Preferences._ctor();
  SharedPreferences _prefs;
  final String _configServer = 'configServer';

  factory Preferences() {
    return _instance;
  }

  Preferences._ctor();

  init() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  get configServer {
    return _prefs.getString(_configServer) ?? '';
  }

  set configServer(String value) {
    _prefs.setString(_configServer, value);
  }
}
