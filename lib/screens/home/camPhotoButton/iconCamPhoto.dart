import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../utils/HexColor.dart';

class IconCamPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        color: HexColor("#2B2B2B"),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Ionicons.ios_camera, color: Colors.white, size: 92),
              SizedBox(height: 10),
              Center(
                  child: Text(
                'Scan & Take Photo',
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              )),
            ]));
  }
}
