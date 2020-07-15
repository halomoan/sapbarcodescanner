import 'package:flutter/material.dart';
import 'iconReader.dart';

class ReaderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IconReader(), onTap: () => _onReaderTap(context));
  }

  void _onReaderTap(BuildContext context) {
    Navigator.pushNamed(context, '/display');
  }
}
