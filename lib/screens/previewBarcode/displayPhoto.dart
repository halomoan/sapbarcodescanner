import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sapfascanner/model/dbHelper.dart';

class DisplayPhoto extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();
  final String imagePath;
  final String barcodeId;

  DisplayPhoto({Key key, this.barcodeId, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
          child: PhotoView(
        imageProvider: FileImage(File(imagePath)),
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newpath = join(
            (await getApplicationDocumentsDirectory()).path,
            '${this.barcodeId}.png',
          );

          await File(imagePath).rename(newpath);

          await _dbHelper.updatePhoto(this.barcodeId, newpath);
        },
        icon: Icon(Icons.save),
        label: Text("Save"),
      ),
    );
  }
}
