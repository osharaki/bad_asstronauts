import "dart:ui";
import "dart:math";
import "package:flame/flame.dart";
import 'package:flame/anchor.dart';
import "package:flame/game.dart";
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:gameOff2020/utils/math.dart';
import 'box.dart';

class BoxGame extends Game with TapDetector {
  Box box;
  Size screenSize;
  double tileSize;
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

    box = Box(
      this,
      spawn: true,
    );
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
    if (!started && !playing) {
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
        counter.toString(),
        Position(
          50,
          screenSize.height - 50,
        ),
      );

      // Playing
    } else if (started && playing) {
      // If Time
      if (timeRemaining > 0) {
        scoreTextConfig.render(
          canvas,
          counter.toString(),
          Position(
            50,
            screenSize.height - 50,
          ),
        );

        textConfig.render(
          canvas,
          timeRemaining.toString(),
          Position(
            screenSize.width - 50,
            screenSize.height - 50,
          ),
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

        box = Box(this, spawn: true);
      }

      // Retry
    } else if (started && !playing) {
      if (timeRemaining > 0) {
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
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
    super.resize(size);
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (mode == "game") {
      // Start Game
      started = true;

      if (box.rect.contains(details.globalPosition)) {
        // Box On Tap Down
        box.onTapDown(details);

        // Create New Box
        box = Box(this);
      } else {
        // Spawn Box
        box = Box(this, spawn: true);

        // Stop Playing
        playing = false;
      }
    }
  }
}
