import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/mainGame.dart';
import 'package:gameOff2020/utils/math.dart';

class Debris {
  MainGame game;
  Rect rect;
  double size;
  Offset position;
  Paint paint = Paint();
  double sizeMultiplier;
  double minSizeMultiplier = 0.1;
  double maxSizeMultiplier = 0.5;

  Debris({@required this.game}) {
    sizeMultiplier = getRandomValueInRange(
      min: minSizeMultiplier,
      max: maxSizeMultiplier,
    );

    size = game.tileSize * sizeMultiplier;

    position = Offset(
      getRandomValueInRange(min: 1, max: 2500.0),
      getRandomValueInRange(min: 1, max: 2500.0),
    );

    rect = Rect.fromCircle(
      center: position,
      radius: size,
    );

    paint.color = Colors.brown[800];
  }

  void update(double t) {
    // Create Debris at arena position
    rect = Rect.fromCircle(
      center: position + game.serverHandler.arena.rect.topLeft,
      radius: size,
    );
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}
