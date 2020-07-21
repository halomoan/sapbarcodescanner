import 'package:flutter/material.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:intl/intl.dart';

import 'customList.dart';

class PreviewBarcode extends StatefulWidget {
  @override
  PreviewBarcodeState createState() => PreviewBarcodeState();
}

class PreviewBarcodeState extends State<PreviewBarcode> {
  final DBHelper _dbHelper = DBHelper();

  SAPFA barcode;
  SCANFA scancode;
  List<SAPFA> barcodes = [];
  final f = new DateFormat('yyyy-MM-dd hh:mm');

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
                  barcodeId: '200010000001',
                  coCode: '2000',
                  mainCode: '1000',
                  subCode: '0001',
                  desc: 'Washing Machine',
                  loc: 'Basement 1',
                  qty: 100);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '200010000001', seq: '0001');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '200010000001', seq: '0002');
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
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return CustomListItem(
                    desc: barcodes[index].desc,
                    tqty: barcodes[index].qty,
                    scanqty: barcodes[index].scanqty,
                    latestdate: f.format(DateTime.fromMillisecondsSinceEpoch(
                        barcodes[index].createdAt * 1000)),
                    thumbnail: Container(
                      decoration: const BoxDecoration(color: Colors.blue),
                    ),
                    barcodeid:
                        "${barcodes[index].coCode}-${barcodes[index].mainCode}-${barcodes[index].subCode}",
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: barcodes.length),
          )
        ],
      )),
    );
  }
}
