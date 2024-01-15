// create stateful widget

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poseapp/camera.dart';

class CameraContainer extends StatefulWidget {
  const CameraContainer({
    super.key,
  });

  @override
  _CameraContainerState createState() => _CameraContainerState();
}

// create state

class _CameraContainerState extends State<CameraContainer> {
  late CameraDescription cameraDescription;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    initPages();
    super.initState();
  }

  initPages() async {
    // _widgetOptions = [const GalleryScreen()];

    // if (cameraIsAvailable) {
    // get list available camera
    cameraDescription = (await availableCameras()).first;
    // _widgetOptions!.add(CameraScreen(camera: cameraDescription));
    // }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('test'),
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        body: Container(child: CameraScreen(camera: cameraDescription)));
  }
}
