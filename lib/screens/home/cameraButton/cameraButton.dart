import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import './iconCamera.dart';

class CameraButton extends StatelessWidget {
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
}
