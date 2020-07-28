import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageWidget extends StatelessWidget {
  String _barcodeId;
  String _filePath;
  File _file;

  ImageWidget(String barcodeId) {
    _barcodeId = barcodeId;
  }

  Future<bool> _hasLocalFile() async {
    _filePath = join(
        (await getApplicationDocumentsDirectory()).path, '$_barcodeId.png');
    try {
      _file = new File(_filePath);
      if (await _file.exists()) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {

    _hasLocalFile.then((val) => {
      return Image.file(_file);
    });
    
  }

  
}
