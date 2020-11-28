import "package:flame/util.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameOff2020/joystick/gameLauncher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  await SystemChrome.setEnabledSystemUIOverlays([]);

  Flame.images.loadAll([
    "spaceship.png",
    "joystickKnob.png",
    "joystickBase.png",
  ]);

  runApp(GameLauncher());
}
