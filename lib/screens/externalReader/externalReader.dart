import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sapfascanner/model/apimodel.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/utils/apiUtil.dart';
import 'package:sapfascanner/utils/barcodeUtils.dart';
import 'package:sapfascanner/utils/imageWidget.dart';

import 'noKeyboardEditableText.dart';

class ExternalReader extends StatefulWidget {
  ExternalReader({Key key}) : super(key: key);

  @override
  _ExternalReaderState createState() => _ExternalReaderState();
}

class _ExternalReaderState extends State<ExternalReader> {
  final DBHelper _dbHelper = DBHelper();
  ApiProvider api = new ApiProvider();
  TextEditingController scanController = TextEditingController();
  FocusNode myFocusNode;
  StreamController<SAPFA> _refreshController;
  BarcodeUtils _barcodeUtils = new BarcodeUtils();

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
        if (scanController.text.length > 0) {
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
        }
        //FocusScope.of(context).requestFocus(new FocusNode());
      }
    });

    _refreshController = new StreamController<SAPFA>();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _refreshController.close();
    super.dispose();
  }

  Widget _scanBarcode(BuildContext contex) {
    return NoKeyboardEditableText(controller: scanController);
  }

  Widget _barcodeInfo(SAPFA barcode) {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "${barcode.coCode} - ${barcode.mainCode} - ${barcode.subCode}",
                style: TextStyle(fontSize: 25),
              ),
              Text(
                "Counter: ${_barcodeUtils.counter}",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                  child: SizedBox(
                      width: 120,
                      height: 120,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: ImageWidget(barcodeId: barcode.barcodeId),
                      ))),
              SizedBox(
                height: 10,
              ),
              Text(
                barcode.desc,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Location: ${barcode.loc}',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              // Text(
              //   'Purchased On: ${barcode.acqdate}',
              //   style: TextStyle(fontSize: 20),
              // ),
              Text(
                'Qty: ${barcode.qty}',
                style: TextStyle(fontSize: 15),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    int iCounter = 0;

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
                  iCounter++;
                  scanController.text =
                      '20002400140000000' + iCounter.toString();
                },
                child: Text('Testing1')),
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
    await _barcodeUtils.setCode(code);

    if (_barcodeUtils.isValid) {
      SAPFA _barcode = _barcodeUtils.sapFA;
      SCANFA _scancode = _barcodeUtils.scanFA;

      if (_barcodeUtils.isNew) {
        _getFAInfo(_barcode.barcodeId);
        _dbHelper.addSAPFA(_barcode);
        _dbHelper.addScanFA(_scancode);
      } else {
        _dbHelper.addScanFA(_scancode);

        if (!_barcode.info) {
          _getFAInfo(_barcode.barcodeId);
        }
      }
      _refreshController.add(_barcode);
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

  _getFAInfo(String barcodeId) async {
    List<String> barcodes = new List<String>();

    barcodes.add(barcodeId);
    FAInfo result = await api.getFAInfo(barcodes);
    if (!result.hasErr) {
      _dbHelper.updateInfo(barcodeId, result);
    }
    SAPFA _barcode = await _dbHelper.getSAPFA(barcodeId);
    if (!_refreshController.isClosed) {
      _refreshController.add(_barcode);
    }
  }
}
