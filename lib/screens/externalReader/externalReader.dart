import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/utils/barcodeUtils.dart';

import 'noKeyboardEditableText.dart';

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
  BarcodeUtils _barcodeUtils = BarcodeUtils();
  String _counter;

  @override
  void initState() {
    super.initState();

    scanController.addListener(() {
      //FocusScope.of(context).requestFocus(myFocusNode);
      //SystemChannels.textInput.invokeMethod('TextInput.hide');
      //FocusScope.of(context).requestFocus(new FocusNode());

      if (_barcodeUtils.validLength < 1) {
        Fluttertoast.showToast(
            msg: 'Invalid Barcode. Please Register This Phone To Get Update.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        scanController.text = '';
        _refreshController.add(null);
        //FocusScope.of(context).requestFocus(new FocusNode());
      } else if (scanController.text.length == _barcodeUtils.validLength) {
        _handleRefresh(scanController.text);
      } else {
        print(scanController.text);
        Fluttertoast.showToast(
            msg: 'Invalid Barcode.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        scanController.text = '';
        _refreshController.add(null);
        //FocusScope.of(context).requestFocus(new FocusNode());
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
    return NoKeyboardEditableText(controller: scanController);
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
                "Counter: $_counter",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                barcode.desc,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                barcode.loc,
                style: TextStyle(fontSize: 20),
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
                style: TextStyle(fontSize: 20),
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
                color: Colors.white,
              ),
            ]),
            Text('Scanned Output'),
            RaisedButton(
                onPressed: () {
                  scanController.text = '200030000010010001';
                },
                child: Text('Testing1')),
            RaisedButton(
                onPressed: () {
                  scanController.text = '200030000010004';
                },
                child: Text('Testing2')),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: _refreshController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? _barcodeInfo(snapshot.data)
                    // : Center(
                    //     child: CircularProgressIndicator(),
                    //   );
                    : Container();
              },
            ),
          ],
        ));
  }

  void _handleRefresh(String code) async {
    _barcodeUtils.code = code;

    if (_barcodeUtils.isValid) {
      List<SAPFA> barcode = await _dbHelper.getSAPFA(_barcodeUtils.barcodeId);
      if (barcode.length > 0) {
        _counter = _barcodeUtils.counter;
        _refreshController.add(barcode.first);
      } else {
        SAPFA _barcode = _barcodeUtils.sapFA;
        _dbHelper.addSAPFA(_barcode);
        SCANFA _scancode = _barcodeUtils.scanFA;
        _dbHelper.addScanFA(_scancode);
        _refreshController.add(_barcode);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Invalid Barcode.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      scanController.text = '';
    }
  }
}
