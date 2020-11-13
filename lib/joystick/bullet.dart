import 'dart:math';

import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Bullet {
  final JoystickGame game;

  final double angle;
  final Offset startPosition;

  Rect rect;
  double size;
  double life = 3;
  Offset position;
  double speed = 1000;
  Paint paint = Paint();
  double sizeMultiplier = 0.1;

  Bullet({
    @required this.game,
    @required this.angle,
    @required this.startPosition,
  }) {
    position = startPosition;
    paint.color = Colors.amber;
    size = game.tileSize * sizeMultiplier;
  }

  void update(double t) {
    // Life Countdown
    life -= t;

    Offset nextOffset = Offset(
      speed * t * cos(angle),
      speed * t * sin(angle),
    );

    position += nextOffset;
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      position,
      size,
      paint,
    );
  }
}
