import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/home/home.dart';
import 'screens/previewBarcode/previewBarcode.dart';
import 'screens/previewBarcode/previewDetail.dart';
import 'screens/cameraUtils/cameraWidget.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/display': (context) => PreviewBarcode(),
        '/detail': (context) => PreviewDetail(),
        '/camera': (context) => CameraWidget()
      },
    );
  }
}
