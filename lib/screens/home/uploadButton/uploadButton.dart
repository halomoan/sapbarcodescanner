import 'package:flutter/material.dart';
import 'iconUpload.dart';

class UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IconUpload(), onTap: () => _onUploadTap(context));
  }

  void _onUploadTap(BuildContext context) {
    Navigator.pushNamed(context, '/display');
  }
}
