import 'dart:core';

import 'package:flutter/material.dart';

class UploadDetail extends StatelessWidget {
  //const UploadDetail({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result = {'codeTotal': 100, 'pictTotal': 10};

    return Container(
      child: Scaffold(
          appBar: AppBar(title: Text('Upload To Server')), body: _infoWidget()),
    );
  }

  Widget _infoWidget() {
    return Container(child: null);
  }
}
