import 'package:flutter/material.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:intl/intl.dart';

class PreviewDetail extends StatefulWidget {
  final SAPFA barcode;

  const PreviewDetail({Key key, this.barcode}) : super(key: key);

  @override
  PreviewDetailState createState() => PreviewDetailState();
}

class PreviewDetailState extends State<PreviewDetail> {
  final DBHelper _dbHelper = DBHelper();
  final f = new DateFormat('yyyy-MM-dd hh:mm a');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.barcode.desc)),
        body: FutureBuilder<List>(
          future: _getData(widget.barcode),
          initialData: List(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? new ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return _buildRow(snapshot.data[i]);
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ));
  }

  Widget _buildRow(SCANFA barcode) {
    return new ListTile(
      title: new Text(
          "${barcode.barcodeId.substring(0, 4)}-${barcode.barcodeId.substring(4, 10)}-${barcode.barcodeId.substring(10, 14)} - ${barcode.seq}",
          style: TextStyle(fontSize: 18.0)),
      subtitle: barcode.createdAt > 0
          ? Text("Scanned On: " +
              f.format(DateTime.fromMillisecondsSinceEpoch(
                  barcode.createdAt * 1000)))
          : Text('Missing',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
              )),
    );
  }

  Future<List<SCANFA>> _getData(SAPFA barcode) {
    return _dbHelper.getItems(barcode.barcodeId, barcode.qty);
  }
}
