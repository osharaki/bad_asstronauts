import 'dart:math';
import "mainGame.dart";
import "package:flutter/material.dart";

class Bullet {
  final MainGame game;

  final double angle;
  final Offset startPosition;

  Rect rect;
  double size;
  double life = 3;
  Offset position;
  Offset offsetPosition;
  double speed = 1000;
  Paint paint = Paint();
  double sizeMultiplier = 0.1;

  Bullet({
    @required this.game,
    @required this.angle,
    @required this.startPosition,
  }) {
    position = startPosition;
    offsetPosition = position;
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

    offsetPosition += nextOffset;
    position = offsetPosition + game.launcher.serverHandler.arena.position;
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      position,
      size,
      paint,
    );
  }
}
