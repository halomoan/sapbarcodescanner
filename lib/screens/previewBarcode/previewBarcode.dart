import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
//import 'package:flutter_icons/flutter_icons.dart';
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
  bool _onlyInvalid = false;

  SAPFA barcode;
  SCANFA scancode;

  @override
  void initState() {
    super.initState();
    _refreshMetadata(true);
  }

  void _selectChoice(Choice choice) {
    switch (choice.id) {
      case 0:
        if (_onlyInvalid) {
          setState(() {
            _onlyInvalid = false;
          });
        }
        break;
      case 1:
        if (!_onlyInvalid) {
          setState(() {
            _onlyInvalid = true;
          });
        }
        break;
      case 2:
        _fixInvalidData();
        break;
      case 3:
        _confirmDelAllDialog();
        break;
      case 4:
        _refreshMetadata(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Barcode"),
        actions: [
          PopupMenuButton<Choice>(
            onSelected: _selectChoice,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                if (_onlyInvalid) {
                  if ([0, 2].contains(choice.id)) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }
                } else {
                  if ([1, 3, 4].contains(choice.id)) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }
                }
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          /*FlatButton(
            child: Text('Add'),
            onPressed: () {
              barcode = SAPFA(
                  barcodeId: '91302400000000',
                  coCode: '9130',
                  mainCode: '240000',
                  subCode: '0000',
                  desc: '',
                  loc: '',
                  qty: 0);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '91302400000000', seq: '0001');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '91302400000000', seq: '0002');
              _dbHelper.addScanFA(scancode);

              barcode = SAPFA(
                  barcodeId: '91302400010000',
                  coCode: '9130',
                  mainCode: '240001',
                  subCode: '0000',
                  desc: '',
                  loc: '',
                  qty: 0);
              _dbHelper.addSAPFA(barcode);

              scancode = SCANFA(barcodeId: '91302400010000', seq: '0003');
              _dbHelper.addScanFA(scancode);
              scancode = SCANFA(barcodeId: '91302400010000', seq: '0002');
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
          ),*/
          SizedBox(
            height: 1,
          ),
          Expanded(
              child: FutureBuilder<List>(
            future: _getData(),
            initialData: List(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return snapshot.hasData && snapshot.data.length > 0
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
                      child: Text(
                        'No Data',
                        style: TextStyle(fontSize: 25),
                      ),
                    );
            },
          ))
        ],
      )),
    );
  }

  Future<List<SAPFA>> _getData() {
    if (_onlyInvalid) {
      return _dbHelper.getInvalidList();
    } else {
      return _dbHelper.getList();
    }
  }

  Future<void> _refreshMetadata(bool delta) async {
    Map<String, dynamic> res;

    res = await api.isConnected();

    if (res['status']) {
      List<SAPFA> items = await _getData();

      List<String> barcodes = new List<String>();

      if (delta) {
        for (final item in items) {
          if (item.info == false) {
            barcodes.add(item.barcodeId);
          }
        }
      } else {
        DefaultCacheManager().emptyCache();
        for (final item in items) {
          barcodes.add(item.barcodeId);
        }
      }

      await _getFAInfo(barcodes);

      if (barcodes.length > 0) {
        print('Refresh');
        setState(() {});
      }
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

  void _fixInvalidData() async {
    bool res = await _dbHelper.delInvalidData();

    if (res) {
      setState(() {
        _onlyInvalid = false;
      });
    }
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

  _getFAInfo(List barcodes) async {
    FAInfo result = await api.getFAInfo(barcodes);
  }
}

class Choice {
  const Choice({this.id, this.title});
  final int id;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(id: 0, title: 'Show All'),
  const Choice(id: 1, title: 'Show Invalid'),
  const Choice(id: 2, title: 'Fix Invalid'),
  const Choice(id: 3, title: 'Delete All'),
  const Choice(id: 4, title: 'Refresh'),
];
