import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'imageBanner.dart';
import 'menuList.dart';

class Home extends StatelessWidget {
  const Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SAP Fixed Assxet Scanner'), actions: [
        IconButton(
          icon: Icon(Ionicons.ios_settings),
          onPressed: () {
            Navigator.pushNamed(context, "/settings");
          },
        ),
      ]),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        MenuList(),
        ImageBanner("assets/images/pphg.png"),
      ]),
    );
  }
}
