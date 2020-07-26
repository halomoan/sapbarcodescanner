import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
  String _barcodeId = "20002000001001";

  @override
  void initState() {
    super.initState();

    scanController.addListener(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
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
      cursorColor: Colors.redAccent,
      enabled: true,
      controller: scanController,
      onChanged: (code) {
        scanController.text = '';
        FocusScope.of(context).requestFocus(myFocusNode);
      },
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      onEditingComplete: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      style: TextStyle(color: Colors.white, fontSize: 40),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        fillColor: Colors.white,
        // focusedBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: Colors.white, width: 2.0)),
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
                barcode.desc,
                style: TextStyle(fontSize: 35),
              ),
              Text(
                barcode.loc,
                style: TextStyle(fontSize: 35),
              ),
              Text(
                'Purchased On: 25-Jan-2020',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Quantity: 1000',
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
                height: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ]),
            Text('Scanned Output'),
            SizedBox(
              height: 10,
            ),
            Text(
              '2000-200000-1001',
              style: TextStyle(fontSize: 40),
            ),
            FutureBuilder(
              future: _getInfo(_barcodeId),
              initialData: null,
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

  Future<SAPFA> _getInfo(String id) async {
    List<SAPFA> barcode = await _dbHelper.getSAPFA(id);
    //return Future.value(barcode.first);
    return Future.delayed(Duration(milliseconds: 2000))
        .then((onValue) => barcode.first);
  }
}
