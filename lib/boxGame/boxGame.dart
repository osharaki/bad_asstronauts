import "dart:ui";
import "dart:math";
import "package:flame/flame.dart";
import 'package:flame/anchor.dart';
import "package:flame/game.dart";
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:gameOff2020/utils/math.dart';
import 'package:vibration/vibration.dart';
import 'box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoxGame extends Game with TapDetector {
  Box box;
  Size screenSize;
  String mode = "game";
  String level = "easy";
  int score = 0;
  Timer interval;
  double timeLimit = 30;
  bool started = false;
  bool playing = false;
  var random = Random();
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

  BoxGame() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    // TODO: add box to a stream builder that subscribes to a position field in the database
    box = Box(
      this,
      spawn: true,
    );

    interval = Timer(
      1,
      repeat: true,
      callback: () => timeLimit -= 1,
    );

    interval.start();
  }

  @override
  void render(Canvas canvas) {
    // Paint BG
    Rect bgRect = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height,
    );
    Paint bgPaint = Paint();
    bgPaint.color = Colors.black;

    canvas.drawRect(bgRect, bgPaint);

    box.render(canvas);

    // Start
    if (!started) {
      textConfig.render(
        canvas,
        "TAP TO PLAY",
        Position(
          screenSize.width / 2,
          screenSize.height / 2 - 100,
        ),
        anchor: Anchor.center,
      );

      scoreTextConfig.render(
        canvas,
        score.toString(),
        Position(
          50,
          screenSize.height - 50,
        ),
      );

      // Playing
    } else if (playing) {
      // If Time
      if (timeLimit > 0) {
        scoreTextConfig.render(
          canvas,
          score.toString(),
          Position(
            50,
            screenSize.height - 50,
          ),
        );

        textConfig.render(
          canvas,
          timeLimit.toStringAsFixed(0),
          Position(
            screenSize.width - 50,
            screenSize.height - 50,
          ),
          anchor: Anchor.center,
        );

        // If Time's Up
      } else {
        // Stop Playing
        playing = false;

        box = Box(this, spawn: true);
      }

      // Retry
    } else if (!playing) {
      if (timeLimit > 0) {
        loseTextConfig.render(
          canvas,
          "YOU LOST!",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 - 125,
          ),
          anchor: Anchor.center,
        );
      } else {
        loseTextConfig.render(
          canvas,
          "TIME'S UP!",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 - 125,
          ),
          anchor: Anchor.center,
        );
      }

      scoreTextConfig.render(
        canvas,
        "Your Score: $score",
        Position(
          screenSize.width / 2,
          screenSize.height / 2 - 90,
        ),
        anchor: Anchor.center,
      );

      textConfig.render(
        canvas,
        "TAP TO REPLAY",
        Position(
          screenSize.width / 2,
          screenSize.height / 2 + 100,
        ),
        anchor: Anchor.center,
      );
    }
  }

  @override
  void update(double t) {
    box.update(t);

    if (playing) {
      interval.update(t);
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
  }

  void onTapDown(TapDownDetails details) async {
    if (box.rect.contains(details.globalPosition)) {
      // Start Game
      if (!started) started = true;

      // Box On Tap Down
      box.onTapDown(details);

      // Create New Box
      box = Box(this);

      // testing Firebase request
      Firestore.instance.collection('test').snapshots().listen((data) {
        print(data.documents[0]['msg']);
      });
    } else {
      if (playing) {
        // Vibration
        if (await Vibration.hasAmplitudeControl()) {
          Vibration.vibrate(
            duration: 1000,
            amplitude: 125,
          );
        } else if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 1000);
        }

        // Spawn Box
        box = Box(this, spawn: true);

        // Stop Playing
        playing = false;
      }
    }
  }
}
