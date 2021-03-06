import 'package:flutter/material.dart';
import 'scanButton/scanButton.dart';
import 'readerButton/readerButton.dart';
//import 'camPhotoButton/camPhotoButton.dart';
import 'previewButton/previewButton.dart';
import 'uploadButton/uploadButton.dart';

class MenuList extends StatelessWidget {
  const MenuList();

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: 400.0),
        child: GridView.count(
            primary: false,
            crossAxisCount: 2,
            padding: const EdgeInsets.all(15.0),
            children: [
              
              CameraButton(),
              ReaderButton(),
              PreviewButton(),
              UploadButton()
            ]));
  }
}
