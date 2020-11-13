import 'package:flame/flame.dart';
import "package:flame/util.dart";
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:flutter/services.dart';
import 'package:gameOff2020/firebaseInit.dart';
import 'package:gameOff2020/boxGame/boxGame.dart';
import 'package:gameOff2020/joystick/joystickGame.dart';

import 'joystick/itemDrag.dart';
import 'joystick/touchData.dart';

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
  int touchCounter = 0;
  final JoystickGame game = JoystickGame();
  // final BoxGame game = BoxGame();

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      child: game.widget,
      gestures: <Type, GestureRecognizerFactory>{
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                ImmediateMultiDragGestureRecognizer>(
          () => ImmediateMultiDragGestureRecognizer(),
          (ImmediateMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset offset) {
              touchCounter++;
              game.onTap(TouchData(touchCounter, offset));
              return ItemDrag((details, tId) {
                game.onDrag(TouchData(tId, details.globalPosition));
              }, (details, tId) {
                game.onRelease(TouchData(tId, Offset(0, 0)));
              }, (tId) {
                game.onCancel(TouchData(tId, Offset(0, 0)));
              }, touchCounter);
            };
          },
        )
      },
    );
  }
}
