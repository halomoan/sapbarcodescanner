import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../utils/HexColor.dart';

class IconUpload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        color: HexColor('#662E9B'),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(AntDesign.upload, color: Colors.blue[50], size: 92),
              SizedBox(height: 10),
              Center(
                  child: Text(
                'Upload To Server',
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              )),
            ]));
  }
}
