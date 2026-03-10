import 'package:async_dispatch/app/app.dart';
import 'package:async_dispatch/bootstrap.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await bootstrap(() =>  AsyncDispatchApp(camera: cameras.first,));
}
