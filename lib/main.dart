import 'package:flutter/material.dart';
import 'package:poseapp/camer_container.dart';
import 'package:poseapp/pose-dectector.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CameraContainer(),
    );
  }
}



class IconButtonExampleApp extends StatelessWidget {
  IconButtonExampleApp () {
    gyroscopeEvents.listen(
          (GyroscopeEvent event) {
        print(event.x);
        // print(event.y);

      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('IconButton Sample')),
        body: const Center(
          child: Text('test') ,
        ),
      ),
    );
  }
}