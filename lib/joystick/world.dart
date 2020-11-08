import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class World {
  JoystickGame game;
  Rect rect;
  Paint paint = Paint();

  World({this.game}) {
    rect = Rect.fromLTWH(0, 0, 1000, 1000);

    paint.color = Colors.indigo[900];
  }

  void update(double t) {}

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}
