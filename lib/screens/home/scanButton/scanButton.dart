import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/utils/barcodeUtils.dart';
import 'iconCamera.dart';

class CameraButton extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();
  final BarcodeUtils _barcodeUtils = BarcodeUtils();

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
        .listen((code) => _processScan(code));
  }

  void _processScan(String code) async {
    await _barcodeUtils.setCode(code);

    _showScan(_barcodeUtils.isValid);
    if (_barcodeUtils.isValid) {
      _saveCode();
    }
  }

  void _showScan(bool status) {
    Fluttertoast.showToast(
        msg: _barcodeUtils.scanCode,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: status ? Colors.blue : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _saveCode() {
    if (_barcodeUtils.isNew) {
      _dbHelper.addSAPFA(_barcodeUtils.sapFA);
    }
    _dbHelper.addScanFA(_barcodeUtils.scanFA);
  }
}
