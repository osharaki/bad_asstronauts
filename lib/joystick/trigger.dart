import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Trigger {
  final JoystickGame game;

  Rect rect;
  double size;
  double sizeMultiplier = 1;
  Offset position;
  Paint paint = Paint();

  Trigger({@required this.game}) {
    size = game.tileSize * sizeMultiplier;
    position = Offset(
      game.screenSize.width - size - 25,
      game.screenSize.height - size - 25,
    );
    rect = Rect.fromCircle(
      center: position,
      radius: size,
    );

    paint.color = Colors.white70;
  }

  void update(double t) {}

  void render(Canvas canvas) {
    canvas.drawCircle(
      position,
      size,
      paint,
    );
  }
}
