import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sapfascanner/model/apimodel.dart';
import 'package:sapfascanner/screens/showUniqueID/showUniqueID.dart';
import 'package:sapfascanner/utils/apiUtil.dart';
import '../../utils/PreferenceUtils.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // bool _showConfigPasswd = false;
  ApiProvider api = new ApiProvider();
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildConfigServer() {
    return TextFormField(
      keyboardType: TextInputType.url,
      initialValue: PreferenceUtils.serverUrl,
      decoration: InputDecoration(
        labelText: 'Server',
        hintText: 'Enter The Server Address',
        icon: const Icon(Icons.cloud),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Server Address is Required';
        }
        return null;
      },
      onSaved: (String value) {
        String url = value;
        if (value.substring(0, 7) == 'http://' ||
            value.substring(0, 8) == 'https://') {
          PreferenceUtils.serverUrl = url;
        } else {
          PreferenceUtils.serverUrl = 'http://' + url;
        }
      },
    );
  }

  Widget _buildLastConnect() {
    int timestamp = PreferenceUtils.lastUpdate;
    String lastUpdate = "";
    if (timestamp > 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      lastUpdate =
          'Last Update: ' + DateFormat('yyyy-MM-dd – h:mm a').format(dateTime);
    }

    return Text(
      lastUpdate,
      style: TextStyle(fontSize: 14),
    );
  }
  // Widget _buildConfigUserID() {
  //   return TextFormField(
  //     initialValue: PreferenceUtils.serverUserID,
  //     decoration: InputDecoration(
  //       labelText: 'User ID',
  //       hintText: 'Enter The Server UserID',
  //       icon: const Icon(Icons.person),
  //     ),
  //     validator: (String value) {
  //       if (value.isEmpty) {
  //         return 'User ID is Required';
  //       }
  //       return null;
  //     },
  //     onSaved: (String value) {
  //       PreferenceUtils.serverUserID = value;
  //     },
  //   );
  // }

  // Widget _buildConfigPasswd() {
  //   return TextFormField(
  //     initialValue: PreferenceUtils.serverPasswd,
  //     obscureText: !_showConfigPasswd,
  //     decoration: InputDecoration(
  //       labelText: 'Password',
  //       hintText: 'Enter The Server Password',
  //       icon: const Icon(Icons.vpn_key),
  //       suffixIcon: GestureDetector(
  //         onTap: () {
  //           setState(() {
  //             _showConfigPasswd = !_showConfigPasswd;
  //           });
  //         },
  //         child: Icon(
  //           _showConfigPasswd ? Icons.visibility : Icons.visibility_off,
  //           color: Colors.black,
  //         ),
  //       ),
  //     ),
  //     validator: (String value) {
  //       if (value.isEmpty) {
  //         return 'Password is Required';
  //       }
  //       return null;
  //     },
  //     onSaved: (String value) {
  //       PreferenceUtils.serverPasswd = value;
  //     },
  //   );
  // }

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
                  //_buildCoCode(),
                  // _buildConfigUserID(),
                  // _buildConfigPasswd(),
                  SizedBox(
                    height: 20,
                  ),
                  isLoading == false
                      ? RaisedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              _connectServer();
                            } else {
                              print("Empty");
                            }
                          },
                          child: Text(
                            "Connect",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        )
                      : Center(child: CircularProgressIndicator()),
                  SizedBox(
                    height: 10,
                  ),
                  _buildLastConnect()
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Future<void> _connectServer() async {
    APIConfig result;
    setState(() {
      isLoading = true;
    });
    result = await api.initApp();
    setState(() {
      isLoading = false;
    });

    if (!result.hasError()) {
      PreferenceUtils.accessToken = result.token;
      PreferenceUtils.coCode = result.cocode;
      PreferenceUtils.coCodeLen = int.parse(result.sub1len);
      PreferenceUtils.mainCodeLen = int.parse(result.sub2len);
      PreferenceUtils.subCodeLen = int.parse(result.sub3len);
      PreferenceUtils.counterLen = int.parse(result.runlen);

      final timestamp = new DateTime.now().millisecondsSinceEpoch;
      PreferenceUtils.lastUpdate = timestamp;

      Fluttertoast.showToast(
          msg: 'Successfully Connected !',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: result.err,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<bool> _checkRegistration() async {
    var result = await api.checkRegistration();
    return result;
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
