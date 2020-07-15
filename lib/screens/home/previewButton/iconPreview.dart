import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../utils/HexColor.dart';

class IconPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        color: HexColor('#7CCAFF'),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Ionicons.ios_list, color: Colors.black, size: 92),
              SizedBox(height: 10),
              Center(
                  child: Text(
                'Display Barcode',
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )),
            ]));
  }
}
