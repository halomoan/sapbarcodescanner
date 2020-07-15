import 'package:flutter/material.dart';
import 'iconPreview.dart';

class PreviewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IconPreview(), onTap: () => _onPreviewTap(context));
  }

  void _onPreviewTap(BuildContext context) {
    Navigator.pushNamed(context, '/display');
  }
}
