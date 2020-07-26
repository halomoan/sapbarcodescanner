import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sapfascanner/utils/PreferenceUtils.dart';
import 'package:clipboard/clipboard.dart';

class ShowUniqueID extends StatelessWidget {
  const ShowUniqueID({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register Unique ID'),
        ),
        body: Container(
          margin: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Please email this phone' 's Unique ID for registration: ',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Text(PreferenceUtils.uniqueID, style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () {
                  print('Pressed');
                  FlutterClipboard.copy(PreferenceUtils.uniqueID)
                      .then((value) => _showCopied());
                },
                child: Text(
                  "Copy To Clipboard",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            ],
          ),
        ));
  }

  void _showCopied() {
    Fluttertoast.showToast(
        msg: 'Unique ID has been copied to clipboard',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue[50],
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
