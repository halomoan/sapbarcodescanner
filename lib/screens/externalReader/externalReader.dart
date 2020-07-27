import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';

class ExternalReader extends StatefulWidget {
  ExternalReader({Key key}) : super(key: key);

  @override
  _ExternalReaderState createState() => _ExternalReaderState();
}

class _ExternalReaderState extends State<ExternalReader> {
  final DBHelper _dbHelper = DBHelper();
  TextEditingController scanController = TextEditingController();
  FocusNode myFocusNode;
  StreamController<SAPFA> _refreshController;
  String _scanText;
  String _counter;

  @override
  void initState() {
    super.initState();

    scanController.addListener(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      FocusScope.of(context).requestFocus(myFocusNode);

      _scanText = scanController.text;
      if (_scanText.length == 18) {
        _handleRefresh(_scanText.substring(0, 14), _scanText.substring(15, 18));
      }
    });

    _refreshController = new StreamController<SAPFA>();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _scanBarcode(BuildContext contex) {
    return TextField(
      focusNode: myFocusNode,
      autofocus: true,
      showCursor: false,
      enabled: true,
      controller: scanController,
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      onEditingComplete: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      style: TextStyle(fontSize: 10),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }

  Widget _barcodeInfo(SAPFA barcode) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "${barcode.coCode} - ${barcode.mainCode} - ${barcode.subCode}",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                "Counter: ${_counter}",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                barcode.desc,
                style: TextStyle(fontSize: 35),
              ),
              Text(
                barcode.loc,
                style: TextStyle(fontSize: 35),
              ),
              Text(
                'Purchased On: ${barcode.acqdate}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Quantity: ${barcode.qty}',
                style: TextStyle(fontSize: 35),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Scan With External Reader')),
        body: Column(
          children: <Widget>[
            Stack(children: <Widget>[
              _scanBarcode(context),
              Container(
                width: double.infinity,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
            ]),
            Text('Scanned Output'),
            RaisedButton(
                onPressed: () {
                  scanController.text = '200010000010010001';
                },
                child: Text('Testing')),
            RaisedButton(
                onPressed: () {
                  setState(() {
                    scanController.text = '200010000010020002';
                  });
                },
                child: Text('Testing')),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: _refreshController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? _barcodeInfo(snapshot.data)
                    : Center(
                        child: CircularProgressIndicator(),
                      );
              },
            ),
          ],
        ));
  }

  void _handleRefresh(String id, String counter) async {
    print(id);
    print(counter);
    List<SAPFA> barcode = await _dbHelper.getSAPFA(id);
    if (barcode.length > 0) {
      _counter = counter;
      _refreshController.add(barcode.first);
      scanController.text = '';
    }
  }
}
