import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/screens/previewBarcode/previewBarcode.dart';

class DisplayPhoto extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();
  final String imagePath;
  final SAPFA barcode;

  DisplayPhoto({Key key, this.barcode, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: barcode.desc == null
              ? Text('Preview Picture')
              : Text('${barcode.desc}')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
          child: PhotoView(
        imageProvider: FileImage(File(imagePath)),
      )),
      floatingActionButton: barcode.photo == null
          ? FloatingActionButton.extended(
              onPressed: () {
                this._save(context);
              },
              icon: Icon(Icons.save),
              label: Text("Save"),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                this._delete(context);
              },
              icon: Icon(Icons.delete),
              label: Text("Delete"),
            ),
    );
  }

  _save(BuildContext context) async {
    final newpath = join(
      (await getApplicationDocumentsDirectory()).path,
      '${this.barcode.barcodeId}.png',
    );

    File f = File(imagePath);

    try {
      if (await f.exists()) {
        File(imagePath).rename(newpath);
      }
    } catch (e) {}

    await _dbHelper.updatePhoto(this.barcode.barcodeId, newpath);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PreviewBarcode()),
      ModalRoute.withName('/'),
    );
  }

  _delete(BuildContext context) async {
    File f = File(imagePath);

    try {
      if (await f.exists()) {
        f.delete();
      }
    } catch (e) {}
    await _dbHelper.updatePhoto(this.barcode.barcodeId, null);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PreviewBarcode()),
      ModalRoute.withName('/'),
    );
  }
}
