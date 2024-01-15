import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'package:image/image.dart' as img;

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }
  test () async {

    final interpreter = await Interpreter.fromAsset('assets/best_model.tfl');

    var input = interpreter.getInputTensors();
    var shape = interpreter.getInputTensors().shape;

    print('PRINT>>>>>${input}');
    print('PRINT>>>>>${shape}');

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }
  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }


 inputImageToTensor(InputImage inputImage)  {
  // Convert the InputImage to a byte array
  // img.Image.
   Uint8List image = inputImage!.bytes!;
  
  // Normalize the pixel values (from 0-255 to 0-1)
  var normalizedBytes = image.map((byte) => byte / 255.0).toList();
  
  // Reshape the byte array to the format expected by the model
  // Assuming the model expects a 1x224x224x3 tensor
  var reshapedBytes = Uint8List.fromList(normalizedBytes!.cast<int>())
      .buffer.asFloat32List()
      .reshape([1, 224, 224, 3]);
  
  return reshapedBytes;
}

  void saveLandmarks(dynamic poseLandmarks, dynamic outputFrame) {
    // Save landmarks.
    if (poseLandmarks != null) {
      // Check the number of landmarks and take pose landmarks.
      assert(poseLandmarks.landmark.length == 33, 'Unexpected number of predicted pose landmarks: ${poseLandmarks.landmark.length}');
      List<List<double>> poseLandmarksList = poseLandmarks.landmark.map((lmk) => [lmk.x, lmk.y, lmk.z]).toList();

      // Map pose landmarks from [0, 1] range to absolute coordinates to get
      // correct aspect ratio.
      List<int> frameShape = outputFrame.shape.sublist(0, 2);
      poseLandmarksList.forEach((lmk) {
        lmk[0] *= frameShape[1];
        lmk[1] *= frameShape[0];
        lmk[2] *= frameShape[1];
      });

      // Write pose sample to CSV.
      List<String> flattenedLandmarks = poseLandmarksList.expand((lmk) => lmk.map((coord) => coord.toStringAsFixed(5))).toList();
      // Convert flattened landmarks to the format required by your model
      // This may involve reshaping, normalization, or any other preprocessing steps
      // Example: Convert the flattened landmarks to a 1D tensor
      // var inputTensor = convertToTensor(flattenedLandmarks);



      // csvOutWriter.writeRow([imageName, poseClassName, ...flattenedLandmarks]);
    }
  }




  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {





      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      // final painter = RectanglePainter();
      _customPaint = CustomPaint(painter: painter);

      // if(poses.isNotEmpty){
      //   var frame = inputImageToTensor(inputImage);
      //
      //
      //   print("frame:::::: ${frame}");
      //
      //
      // }
      // _customPaint = RectanglePainter();
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}



class RectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double rectangleWidth = 300.0;
    final double rectangleHeight = 600.0;

    final Rect rectangle = Rect.fromCenter(
      center: Offset(centerX, centerY + 2),
      width: rectangleWidth,
      height: rectangleHeight,
    );

    canvas.drawRect(rectangle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
