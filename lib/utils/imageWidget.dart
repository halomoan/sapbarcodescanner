import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageWidget extends StatelessWidget {
  final String barcodeId;

  const ImageWidget({Key key, this.barcodeId}) : super(key: key);

  Future<Image> getImage() async {
    String _filePath =
        join((await getApplicationDocumentsDirectory()).path, '$barcodeId.png');
    try {
      File f = new File(_filePath);
      if (await f.exists()) {
        return Image.file(f);
      } else {
        f = await DefaultCacheManager()
            .getSingleFile('https://via.placeholder.com/150');
        return Image.file(f);
      }
    } on Exception catch (e) {
      print('error caught: $e');
    } catch (e) {}
    return Image.asset("assets/images/barcode.png");
  }

  Future<ImageProvider<dynamic>> getImageProvider() async {
    String _filePath =
        join((await getApplicationDocumentsDirectory()).path, '$barcodeId.png');
    try {
      File f = new File(_filePath);
      if (await f.exists()) {
        return FileImage(f);
      } else {
        f = await DefaultCacheManager()
            .getSingleFile('https://via.placeholder.com/150');
        return FileImage(f);
      }
    } catch (e) {
      return AssetImage("assets/images/barcode.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: getImage(),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data;
        } else {
          // Otherwise, display a loading indicator.
          return Image.asset("assets/images/barcode.png");
        }
      },
    );
  }
}
