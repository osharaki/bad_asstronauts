import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Enemy {
  JoystickGame game;
  Rect rect;
  Paint paint = Paint();

  Enemy({this.game}) {
    rect = Rect.fromLTWH(250, 250, 25, 25);

    paint.color = Colors.red;
  }

  void update(double t) {}

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}
