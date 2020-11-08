import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Planet {
  // Instance Variables
  JoystickGame game;

  Rect rect;
  Paint paint = Paint();

  double size;
  double sizeMultiplier = 4;

  Planet({this.game}) {
    initialize();
  }

  void initialize() {
    size = game.tileSize * sizeMultiplier;

    rect = Rect.fromCircle(
      center: Offset(750, 300),
      radius: size,
    );

    paint.color = Colors.blue;
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
    canvas.drawCircle(rect.center, size, paint);
  }
}
