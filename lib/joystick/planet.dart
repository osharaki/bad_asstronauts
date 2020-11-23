import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/mainGame.dart';

class Planet {
  // Instance Variables
  MainGame game;

  Rect rect;
  Paint paint = Paint();

  Offset position;

  double size;
  double sizeMultiplier = 2.5;

  Planet({this.game}) {
    initialize();
  }

  void initialize() {
    size = game.tileSize * sizeMultiplier;

    position = Offset(750, 300);

    rect = Rect.fromCircle(
      center: position,
      radius: size,
    );

    paint.color = Colors.blue;
  }

  void update(double t) {
    // Create Planet at arena position
    rect = Rect.fromCircle(
      center: position + game.serverHandler.arena.position,
      radius: size,
    );
  }

  void render(Canvas canvas) {
    // Render Rect
    canvas.drawCircle(rect.center, size, paint);
  }
}
