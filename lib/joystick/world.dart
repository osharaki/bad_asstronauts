import "package:flutter/material.dart";

import 'joystickGame.dart';

class World {
  // Instance Variables
  JoystickGame game;

  Rect rect;
  Paint paint = Paint();

  World({this.game}) {
    rect = Rect.fromLTWH(0, 0, 2500, 2500);

    paint.color = Colors.indigo[900];
  }

  void update(double t) {
    // Spaceship's offset from it's next position
    var difference = Offset(
          rect.center.dx - game.joystick.nextOffset.dx,
          rect.center.dy - game.joystick.nextOffset.dy,
        ) -
        rect.center;

    // Shift Spaceship to it's next position
    rect = rect.shift(difference);
  }

  void render(Canvas canvas) {
    // Render Rect
    canvas.drawRect(rect, paint);
  }
}
