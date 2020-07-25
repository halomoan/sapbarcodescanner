import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../utils/HexColor.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';

class IconCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        color: HexColor("#00688E"),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Ionicons.ios_camera, color: Colors.white, size: 92),
              SizedBox(height: 10),
              Center(
                  child: Text(
                'Scan Continuously',
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              )),
            ]));
  }
}
