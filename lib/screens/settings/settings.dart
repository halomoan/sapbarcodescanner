import 'package:flutter/material.dart';
import 'package:sapfascanner/screens/showUniqueID/showUniqueID.dart';
import '../../utils/PreferenceUtils.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _showConfigPasswd = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildConfigServer() {
    return TextFormField(
      keyboardType: TextInputType.url,
      initialValue: PreferenceUtils.configServer,
      decoration: InputDecoration(
        labelText: 'Server',
        hintText: 'Enter The Server Address',
        icon: const Icon(Icons.cloud),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Config Server is Required';
        }
        return null;
      },
      onSaved: (String value) {
        PreferenceUtils.configServer = value;
      },
    );
  }

  Widget _buildConfigUserID() {
    return TextFormField(
      initialValue: PreferenceUtils.configUserID,
      decoration: InputDecoration(
        labelText: 'User ID',
        hintText: 'Enter The Server UserID',
        icon: const Icon(Icons.person),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'User ID is Required';
        }
        return null;
      },
      onSaved: (String value) {
        PreferenceUtils.configUserID = value;
      },
    );
  }

  Widget _buildConfigPasswd() {
    return TextFormField(
      initialValue: PreferenceUtils.configPasswd,
      obscureText: !_showConfigPasswd,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter The Server Password',
        icon: const Icon(Icons.vpn_key),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showConfigPasswd = !_showConfigPasswd;
            });
          },
          child: Icon(
            _showConfigPasswd ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Config Password is Required';
        }
        return null;
      },
      onSaved: (String value) {
        PreferenceUtils.configPasswd = value;
      },
    );
  }

  Widget _formWidget() {
    return FutureBuilder(
      future: _checkRegistration(),
      initialData: null,
      builder: (context, registered) {
        return registered.hasData
            ? new ListView(
                children: <Widget>[
                  Visibility(
                    visible: !registered.data,
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            PreferenceUtils.coCodeLen = 4;
                            PreferenceUtils.mainCodeLen = 6;
                            PreferenceUtils.subCodeLen = 4;
                            PreferenceUtils.counterLen = 4;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowUniqueID()),
                            );
                          },
                          child: Text(
                            "Register This Phone",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  _buildConfigServer(),
                  _buildConfigUserID(),
                  _buildConfigPasswd(),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                      } else {
                        print("Empty");
                      }
                    },
                    child: Text(
                      "Connect",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Future<bool> _checkRegistration() {
    // var result = await http.get('https://getProjectList');
    // return result;
    return Future.delayed(Duration(milliseconds: 2000))
        .then((onValue) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: _formWidget(),
          )),
    );
  }
}
