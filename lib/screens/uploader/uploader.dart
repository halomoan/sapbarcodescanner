import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sapfascanner/utils/uploadUtil.dart';

class Uploader extends StatefulWidget {
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final UploadUtils _util = new UploadUtils();
  Map<String, dynamic> res;
  StreamController<String> _progress;
  bool _inProgress = false;

  @override
  initState() {
    super.initState();
    _progress = new StreamController<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Upload To Server')), body: _infoWidget());
  }

  Widget _infoWidget() {
    return Container(
        child: FutureBuilder(
      future: _util.getUploadInfo(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }

        var result = snapshot.data;

        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Scanned Barcode: ${result["codeTotal"]}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Total Scanned Barcode: ${result["pictTotal"]}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 40,
            ),
            _inProgress
                ? StreamBuilder(
                    stream: _progress.stream,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Text('In Progress: ${snapshot.data}')
                          : Container();
                    },
                  )
                : Container(),
            SizedBox(
              height: 40,
            ),
            RaisedButton(
                onPressed: () async {
                  _inProgress = true;
                  res = await _util.doUpload(_progress);
                  _inProgress = false;
                  if (!res['status']) {
                    Fluttertoast.showToast(
                        msg: res['msg'],
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    Fluttertoast.showToast(
                        msg: res['msg'],
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text('Upload Now')),
          ],
        ));
      },
    ));
  }

  @override
  void dispose() {
    _progress.close();
    super.dispose();
  }
}
