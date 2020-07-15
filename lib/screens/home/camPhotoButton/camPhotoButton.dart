import 'package:flutter/material.dart';
import 'iconCamPhoto.dart';

class CamPhotoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IconCamPhoto(), onTap: () => _onTakePhotoTap(context));
  }

  void _onTakePhotoTap(BuildContext context) {
    Navigator.pushNamed(context, '/camera');
  }
}
