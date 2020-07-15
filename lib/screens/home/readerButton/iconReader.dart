import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../../../utils/HexColor.dart';

class IconReader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        color: HexColor('#FFFFFF'),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(AntDesign.barcode, color: Colors.red, size: 92),
              SizedBox(height: 10),
              Center(
                  child: Text(
                'Scan With Reader',
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )),
            ]));
  }
}
