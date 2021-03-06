import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapfascanner/screens/externalReader/externalReader.dart';
import 'package:sapfascanner/screens/uploader/uploader.dart';
import 'screens/home/home.dart';
import 'screens/previewBarcode/previewBarcode.dart';
import 'screens/previewDetail/previewDetail.dart';
import 'screens/settings/settings.dart';
import 'utils/PreferenceUtils.dart';
import 'camera/camera.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAP Fixed Asset Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/display': (context) => PreviewBarcode(),
        '/detail': (context) => PreviewDetail(),
        '/external': (context) => ExternalReader(),
        '/settings': (context) => Settings(),
        '/upload': (context) => Uploader(),
        '/camera': (context) => Camera()
      },
    );
  }
}
