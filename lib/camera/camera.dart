import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/screens/displayPhoto/displayPhoto.dart';

class Camera extends StatefulWidget {
  final SAPFA barcode;

  const Camera({Key key, this.barcode}) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  List<CameraDescription> cameras;
  CameraController _controller;
  bool isReady = false;
  Future<void> _initializeControllerFuture;

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      _controller =
          new CameraController(cameras.first, ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
    } on CameraException catch (_) {
      setState(() {
        isReady = false;
      });
    }
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${widget.barcode.barcodeId}.png',
            );

            File f = new File(path);
            try {
              if (await f.exists()) {
                f.delete();
                // Attempt to take a picture and log where it's been saved.
                await _controller.takePicture(path);
              } else {
                // Attempt to take a picture and log where it's been saved.
                await _controller.takePicture(path);
              }
            } catch (e) {
              print('error caught: $e');
            }

            // If the picture was taken, display it on a new screen.
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DisplayPhoto(barcode: widget.barcode, imagePath: path),
              ),
              ModalRoute.withName('/'),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
