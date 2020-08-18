import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sapfascanner/model/apimodel.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/utils/apiUtil.dart';
import 'package:sapfascanner/utils/imageWidget.dart';

import 'customList.dart';

class PreviewBarcode extends StatefulWidget {
  @override
  PreviewBarcodeState createState() => PreviewBarcodeState();
}

class PreviewBarcodeState extends State<PreviewBarcode> {
  final DBHelper _dbHelper = DBHelper();
  final ApiProvider api = new ApiProvider();

  SAPFA barcode;
  SCANFA scancode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Barcode"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, size: 25.0),
            onPressed: () {
              _confirmDelAllDialog();
            },
          ),
          IconButton(
            icon: Icon(Ionicons.ios_refresh),
            onPressed: () {
              _refreshMetadata();
            },
          ),
        ],
      ),
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
                  desc: '',
                  loc: '',
                  qty: 0);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '20001000001002', seq: '0001');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20001000001002', seq: '0002');
              _dbHelper.addScanFA(scancode);

              barcode = SAPFA(
                  barcodeId: '20002000001002',
                  coCode: '2000',
                  mainCode: '200000',
                  subCode: '1002',
                  desc: '',
                  loc: '',
                  qty: 0);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '20002000001002', seq: '0003');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '20002000001002', seq: '0002');
              _dbHelper.addScanFA(scancode);
            },
            color: Colors.blue,
            textColor: Colors.white,
          ),
          FlatButton(
            child: Text('Show'),
            onPressed: () async {
              List<SAPFA> list = await _dbHelper.getList();

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
                            thumbnail: ImageWidget(
                                barcodeId: snapshot.data[index].barcodeId),
                            callback: this._setState);
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

  Future<void> _refreshMetadata() async {
    Map<String, dynamic> res;

    res = await api.isConnected();

    if (res['status']) {
      List<SAPFA> items = await _getData();
      DefaultCacheManager().emptyCache();
      for (final item in items) {
        _getFAInfo(item.barcodeId);
      }
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: res['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _setState() {
    setState(() {});
  }

  void _confirmDelAllDialog() {
    bool _confirm = false;

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget deleteButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        _dbHelper.reset();
        _setState();
        Navigator.of(context).pop();
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Delete Confirmation"),
              titlePadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              contentPadding: EdgeInsets.fromLTRB(2, 2, 2, 2),
              content: Container(
                  height: 60,
                  width: 100,
                  child: Column(children: [
                    CheckboxListTile(
                      value: _confirm,
                      title: Text("Yes. I want to delete all codes"),
                      onChanged: (value) {
                        setState(() {
                          _confirm = value;
                        });
                      },
                    ),
                  ])),
              actions: [
                cancelButton,
                _confirm ? deleteButton : Container(),
              ],
            );
          },
        );
      },
    );
  }

  _getFAInfo(String barcodeId) async {
    FAInfo result = await api.getFAInfo(barcodeId);
    if (!result.hasErr) {
      _dbHelper.updateInfo(barcodeId, result);
    }
  }
}
