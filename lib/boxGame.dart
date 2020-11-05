import "dart:ui";
import "dart:math";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/anchor.dart';
import "package:flame/game.dart";
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:gameOff2020/utils/math.dart';

class BoxGame extends Game with TapDetector {
  Size screenSize;
  String mode = "game";
  String level = "easy";
  int tick = 0;
  int time = 0;
  int timeLimit = 30;
  int timeRemaining = 30;
  int score = 0;
  int counter = 0;
  bool playing = false;
  bool started = false;
  var random = Random();
  var boxSize = Size(50, 50);
  var boxColor = Colors.white;
  var boxPosition = Offset(0, 0);
  var textConfig = TextConfig(
    color: Colors.white,
    textAlign: TextAlign.center,
  );
  var loseTextConfig = TextConfig(
    color: Colors.red,
    fontSize: 50,
    textAlign: TextAlign.center,
  );

  var scoreTextConfig = TextConfig(
    color: Colors.white,
    fontSize: 20,
    textAlign: TextAlign.center,
  );

  @override
  void render(Canvas canvas) {
    // Paint Black BG
    Rect bgRect = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height,
    );
    Paint bgPaint = Paint();
    bgPaint.color = Colors.black;

    canvas.drawRect(bgRect, bgPaint);

    // Paint Box
    double xScreenCenter = screenSize.width / 2;
    double yScreenCenter = screenSize.height / 2;

    Rect boxRect = Rect.fromLTWH(
      xScreenCenter - boxSize.width / 2 + boxPosition.dx,
      yScreenCenter - boxSize.height / 2 + boxPosition.dy,
      boxSize.width,
      boxSize.height,
    );
    Paint boxPaint = Paint();
    boxPaint.color = (playing) ? boxColor : Colors.white;

    canvas.drawRect(boxRect, boxPaint);

    // Start
    if (!started && !playing) {
      textConfig.render(
        canvas,
        "TAP TO PLAY",
        Position(xScreenCenter, yScreenCenter - 100),
        anchor: Anchor.center,
      );

      scoreTextConfig.render(
        canvas,
        counter.toString(),
        Position(50, screenSize.height - 50),
      );

      // Playing
    } else if (started && playing) {
      // If Time
      if (timeRemaining > 0) {
        scoreTextConfig.render(
          canvas,
          counter.toString(),
          Position(50, screenSize.height - 50),
        );

        textConfig.render(
          canvas,
          timeRemaining.toString(),
          Position(screenSize.width - 50, screenSize.height - 50),
          anchor: Anchor.center,
        );

        // Time
        tick += 1;
        time = (tick / 60).floor();
        timeRemaining = timeLimit - time;

        // If Time's Up
      } else {
        // Stop Playing
        playing = false;

        // Position
        boxPosition = Offset(0, 0);
      }

      // Retry
    } else if (started && !playing) {
      if (timeRemaining > 0) {
        loseTextConfig.render(
          canvas,
          "YOU LOST!",
          Position(xScreenCenter, yScreenCenter - 125),
          anchor: Anchor.center,
        );
      } else {
        loseTextConfig.render(
          canvas,
          "TIME'S UP!",
          Position(xScreenCenter, yScreenCenter - 125),
          anchor: Anchor.center,
        );
      }

      scoreTextConfig.render(
        canvas,
        "Your Score: $score",
        Position(xScreenCenter, yScreenCenter - 90),
        anchor: Anchor.center,
      );

      textConfig.render(
        canvas,
        "TAP TO REPLAY",
        Position(xScreenCenter, yScreenCenter + 100),
        anchor: Anchor.center,
      );
    }
  }

  @override
  void update(double t) {
    // Implement Update
  }

  @override
  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (mode == "game") {
      // Start Game
      started = true;

      double xScreenCenter = screenSize.width / 2;
      double yScreenCenter = screenSize.height / 2;

      if (details.globalPosition.dx >= xScreenCenter - boxSize.width / 2 + boxPosition.dx &&
          details.globalPosition.dx <= xScreenCenter + boxSize.width / 2 + boxPosition.dx &&
          details.globalPosition.dy >= yScreenCenter - boxSize.height / 2 + boxPosition.dy &&
          details.globalPosition.dy <= yScreenCenter + boxSize.height / 2 + boxPosition.dy) {
        //
        if (!playing) {
          // Score
          counter = 0;

          // Time
          tick = 0;
          time = 0;
          timeRemaining = timeLimit;
        }

        // testing Firebase request
        Firestore.instance
            .collection('test')
            .snapshots()
            .listen((data) {
          print(data.documents[0]['msg']);
        });

        // Color
        boxColor =
            Color.fromARGB(255, random.nextInt(255), random.nextInt(255), random.nextInt(255));

        // Position
        boxPosition = Offset(
            getRandomValueInRange(
              min: (xScreenCenter.toInt() - boxSize.width ~/ 2) * -1,
              max: (xScreenCenter.toInt() - boxSize.width ~/ 2),
            ).toDouble(),
            getRandomValueInRange(
              min: (yScreenCenter.toInt() - boxSize.height ~/ 2) * -1,
              max: (yScreenCenter.toInt() - boxSize.height ~/ 2),
            ).toDouble());

        // Score
        counter += 1;
        score = counter;

        // Start Playing
        playing = true;
      } else {
        // Stop Playing
        playing = false;

        // Position
        boxPosition = Offset(0, 0);
      }
    }
  }
}
