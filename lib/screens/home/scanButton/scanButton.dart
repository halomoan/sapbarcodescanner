import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'iconCamera.dart';

class CameraButton extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IconCamera(), onTap: () => _onCameraTap(context));
  }

  void _onCameraTap(BuildContext context) {
    this.startBarcodeScanStream();
  }

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)
        .listen((barcode) => _showScan(barcode));
  }

  void _showScan(String barcode) {
    Fluttertoast.showToast(
        msg: barcode,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  bool _validateCode(String barcode) {
    return false;
  }

  void _saveCode(String barcode) {
    var itemFA = SAPFA(
        barcodeId: '20002000001001',
        coCode: '2000',
        mainCode: '200000',
        subCode: '1001',
        desc: 'Machine A',
        loc: 'Level 2',
        qty: 300);
    _dbHelper.addSAPFA(itemFA);

    var itemScan = SCANFA(barcodeId: '20002000001001', seq: '0001');
    _dbHelper.addScanFA(itemScan);
  }
}
