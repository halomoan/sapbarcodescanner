import 'package:flutter/material.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';

class PreviewBarcode extends StatefulWidget {
  @override
  PreviewBarcodeState createState() => PreviewBarcodeState();
}

class PreviewBarcodeState extends State<PreviewBarcode> {
  final DBHelper _dbHelper = DBHelper();

  SAPFA barcode;
  List<SAPFA> barcodes = [];

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
                  barcodeId: '2000100000010001',
                  coCode: '2000',
                  mainCode: '1000',
                  subCode: '0001',
                  desc: 'Washing Machine',
                  loc: 'Basement 1',
                  qty: 100);
              _dbHelper.addSAPFA(barcode);
            },
            color: Colors.blue,
            textColor: Colors.white,
          ),
          FlatButton(
            child: Text('Show'),
            onPressed: () async {
              List<SAPFA> _list = await _dbHelper.getSAPFA();

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
                  return ListTile(
                      leading: Container(
                        decoration: const BoxDecoration(color: Colors.blue),
                      ),
                      trailing: Column(children: <Widget>[
                        Icon(Icons.warning),
                        Icon(Icons.arrow_forward)
                      ]),
                      title: Text(
                          "${barcodes[index].coCode}-${barcodes[index].mainCode}-${barcodes[index].subCode}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${barcodes[index].desc}"),
                          Text(barcodes[index].qty == null
                              ? "QTY: 0"
                              : "QTY: ${barcodes[index].qty}"),
                        ],
                      ));
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: barcodes.length),
          )
        ],
      )),
    );
  }
}
