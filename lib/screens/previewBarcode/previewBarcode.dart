import 'package:flutter/material.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/utils/imageWidget.dart';

import 'customList.dart';

class PreviewBarcode extends StatefulWidget {
  @override
  PreviewBarcodeState createState() => PreviewBarcodeState();
}

class PreviewBarcodeState extends State<PreviewBarcode> {
  final DBHelper _dbHelper = DBHelper();

  SAPFA barcode;
  SCANFA scancode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview Barcode")),
      body: Center(
          child: Column(
        children: <Widget>[
          FlatButton(
            child: Text('Add'),
            onPressed: () {
              barcode = SAPFA(
                  barcodeId: '20001000001002',
                  coCode: '2000',
                  mainCode: '100000',
                  subCode: '1002',
                  desc: 'Machine B',
                  loc: 'Level 1',
                  qty: 300);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '20001000001002', seq: '0001');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20001000001002', seq: '0002');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20001000001002', seq: '0007');
              _dbHelper.addScanFA(scancode);
            },
            color: Colors.blue,
            textColor: Colors.white,
          ),
          FlatButton(
            child: Text('Show'),
            onPressed: () async {
              List<SAPFA> _list = await _dbHelper.getList();

              print(_list.length);

              setState(() {
                //barcodes = _list;
              });
            },
            color: Colors.red,
            textColor: Colors.white,
          ),
          FlatButton(
            child: Text('Reset'),
            onPressed: () async {
              await _dbHelper.reset();
              setState(() {
                //barcodes = _list;
              });
            },
            color: Colors.red,
            textColor: Colors.white,
          ),
          Expanded(
              child: FutureBuilder<List>(
            future: _getData(),
            initialData: List(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? new ListView.separated(
                      itemBuilder: (context, index) {
                        return CustomListItem(
                          barcode: snapshot.data[index],
                          thumbnail:
                              ImageWidget(snapshot.data[index].barcodeId),
                        );
                      },
                      separatorBuilder: (context, index) => Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.white),
                      itemCount: snapshot.data.length)
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ))
        ],
      )),
    );
  }

  Future<List<SAPFA>> _getData() {
    return _dbHelper.getList();
  }
}
