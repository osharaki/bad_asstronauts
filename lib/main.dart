import 'package:flame/flame.dart';
import "package:flame/util.dart";
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:flutter/services.dart';
import 'package:gameOff2020/boxGame/boxGame.dart';
import 'package:gameOff2020/joystick/joystickGame.dart';
import 'package:gameOff2020/firebaseInit.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final JoystickGame game = JoystickGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: GestureDetector(
          onPanStart: game.onPanStart,
          onPanUpdate: game.onPanUpdate,
          onPanEnd: game.onPanEnd,
          child: game.widget,
        ),
      ),
    );
  }
}
