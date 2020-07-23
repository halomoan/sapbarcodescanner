import 'package:flutter/material.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:intl/intl.dart';
import 'previewDetail.dart';

import 'customList.dart';

class PreviewBarcode extends StatefulWidget {
  @override
  PreviewBarcodeState createState() => PreviewBarcodeState();
}

class PreviewBarcodeState extends State<PreviewBarcode> {
  final DBHelper _dbHelper = DBHelper();

  SAPFA barcode;
  SCANFA scancode;
  List<dynamic> barcodes = [];
  final f = new DateFormat('yyyy-MM-dd hh:mm a');

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
                  barcodeId: '20007000001001',
                  coCode: '2000',
                  mainCode: '700000',
                  subCode: '1001',
                  desc: 'Escalator',
                  loc: 'Level 1',
                  qty: 15);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '20007000001001', seq: '0014');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20007000001001', seq: '0012');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20007000001001', seq: '0002');
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
                barcodes = _list;
              });
            },
            color: Colors.red,
            textColor: Colors.white,
          ),
          FlatButton(
            child: Text('Reset'),
            onPressed: () async {
              await _dbHelper.reset();
            },
            color: Colors.red,
            textColor: Colors.white,
          ),
          Expanded(
              child: FutureBuilder<List>(
            future: _getData(),
            initialData: List(),
            builder: (context, snapshot) {
              barcodes = snapshot.data;
              return snapshot.hasData
                  ? new ListView.separated(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            child: CustomListItem(
                              desc: barcodes[index].desc,
                              tqty: barcodes[index].qty,
                              scanqty: barcodes[index].scanqty,
                              latestdate: f.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      barcodes[index].createdAt * 1000)),
                              thumbnail: Image.asset(
                                "assets/images/barcode.png",
                                fit: BoxFit.fill,
                              ),
                              barcodeid:
                                  "${barcodes[index].coCode}-${barcodes[index].mainCode}-${barcodes[index].subCode}",
                            ),
                            onTap: () => _onItemTap(
                                context,
                                barcodes[index].barcodeId,
                                barcodes[index].desc,
                                barcodes[index].qty));
                      },
                      separatorBuilder: (context, index) => Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.white),
                      itemCount: barcodes.length)
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

  _onItemTap(BuildContext context, String id, String text, int qty) {
    //print('Go Next $id');
    //Navigator.pushNamed(context, "/detail");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewDetail(id: id, text: text, qty: qty)));
  }
}
