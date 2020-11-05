import 'dart:math';
import "boxGame.dart";
import "../utils/math.dart";
import "package:flutter/material.dart";

class Box {
  Rect rect;
  Paint paint;
  double size = 50;
  final BoxGame game;
  var random = Random();

  Box(this.game, {bool spawn = false}) {
    paint = Paint();

    if (spawn) {
      rect = Rect.fromLTWH(
        (game.screenSize.width / 2) - (size / 2),
        (game.screenSize.height / 2) - (size / 2),
        size,
        size,
      );

      paint.color = Colors.white;
    } else {
      rect = Rect.fromLTWH(
        getRandomValueInRange(
          min: 0,
          max: (game.screenSize.width - size).toInt(),
        ).toDouble(),
        getRandomValueInRange(
          min: 0,
          max: (game.screenSize.height - size).toInt(),
        ).toDouble(),
        size,
        size,
      );

      paint.color = Color.fromARGB(
        255,
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
      );
    }
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }

  void update(double t) {}

  void onTapDown(TapDownDetails details) {
    if (!game.playing) {
      // Score
      game.counter = 0;
      game.score = game.counter;

      // Time
      game.tick = 0;
      game.time = 0;
      game.timeRemaining = game.timeLimit;
    } else {
      // Score
      game.counter += 1;
      game.score = game.counter;
    }

    // Start Playing
    game.playing = true;
  }
}
