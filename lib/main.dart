import "package:flame/util.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

import 'mainGame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  await SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MainGame().widget);
}
