import "package:flame/util.dart";
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:flutter/gestures.dart";
import "package:gameOff2020/boxGame.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeLeft);

  var boxGame = BoxGame();
  var tapper = TapGestureRecognizer();
  tapper.onTapDown = boxGame.onTapDown;

  runApp(boxGame.widget);
}
