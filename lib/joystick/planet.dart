import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Planet {
  JoystickGame game;
  Rect rect;
  double radius = 75;
  Paint paint = Paint();

  Planet({this.game}) {
    rect = Rect.fromCircle(
      center: Offset(50, 50),
      radius: radius,
    );

    paint.color = Colors.blue;
  }

  void update(double t) {}

  void render(Canvas canvas) {
    canvas.drawCircle(rect.center, radius, paint);
  }
}
