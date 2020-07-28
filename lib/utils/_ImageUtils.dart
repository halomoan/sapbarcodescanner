import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageUtils {
  String _barcodeId;
  String _filePath;
  File _file;
  BuildContext _context;

  ImageUtils(BuildContext context, String barcodeId) {
    _barcodeId = barcodeId;
    _context = context;
  }

  Future<bool> get _hasLocalFile async {
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

  Future<Widget> get getImage async {
    if (await _hasLocalFile) {
      return Image.file(_file);
    } else {
      return CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(),
        imageUrl: 'https://picsum.photos/250?image=9',
      );
    }
  }
}
