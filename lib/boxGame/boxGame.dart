import "dart:ui";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gameOff2020/auth.dart';
import 'package:gameOff2020/boxGame/services/services.dart';

import 'box.dart';
import "dart:math";
import 'package:flame/time.dart';
import "package:flame/game.dart";
import "package:flame/flame.dart";
import 'package:flame/anchor.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:flame/text_config.dart';
import 'package:vibration/vibration.dart';
import 'package:gameOff2020/utils/math.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoxGame extends Game with TapDetector {
  //Auth
  bool signedIn = false;

  // UI
  Box box;

  // Gameplay
  int score = 0;
  int opponentScore = 0;
  Timer interval;
  double timeLimit = 30;
  bool playing = false;
  bool started = false;

  // Modes
  String mode = "game";
  String level = "easy";

  // Spacial
  Size screenSize;
  double tileSize;

  // Variables
  var random = Random();

  // Text Configs
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
    color: Colors.blue[900],
    fontSize: 20,
    textAlign: TextAlign.center,
  );

  var opponentScoreTextConfig = TextConfig(
    color: Colors.red[900],
    fontSize: 20,
    textAlign: TextAlign.center,
  );

  BoxGame() {
    initialize();
  }

  void initialize() async {
    // Auth
    FirebaseAuth.instance.authStateChanges().listen(
      (User user) {
        if (user == null) {
          print('❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗');
          print('User currently signed out');
          signedIn = false;
        } else {
          print('✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️');
          print('User signed in!');
          signedIn = true;
        }
      },
    );
    resize(await Flame.util.initialDimensions());

    box = Box(
      game: this,
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

    if (box != null) box.render(canvas);

    if (!signedIn) {
      textConfig.render(
        canvas,
        "TAP TO JOIN A GAME",
        Position(
          screenSize.width / 2,
          screenSize.height / 2 - 70,
        ),
        anchor: Anchor.center,
      );
    } else {
      // Start
      if (!started) {
        textConfig.render(
          canvas,
          "TAP BOX TO PLAY",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 - 100,
          ),
          anchor: Anchor.center,
        );
        TextConfig(
          fontSize: 20,
          color: Colors.white,
          textAlign: TextAlign.center,
        ).render(
          (canvas),
          "tap outside to sign out",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 + 60,
          ),
          anchor: Anchor.center,
        );

        // Playing
      } else if (playing) {
        // If Time
        if (timeLimit > 0) {
          // Your Score
          scoreTextConfig.render(
            canvas,
            score.toString(),
            Position(
              (screenSize.width / 2) - 25,
              screenSize.height - 50,
            ),
            anchor: Anchor.bottomRight,
          );

          // Separator
          textConfig.render(
            canvas,
            "|",
            Position(
              screenSize.width / 2,
              screenSize.height,
            ),
            anchor: Anchor.center,
          );

          // Opponent Score
          opponentScoreTextConfig.render(
            canvas,
            opponentScore.toString(),
            Position(
              (screenSize.width / 2) + 25,
              screenSize.height - 50,
            ),
            anchor: Anchor.bottomLeft,
          );

          textConfig.render(
            canvas,
            timeLimit.toStringAsFixed(0),
            Position(
              screenSize.width / 2,
              50,
            ),
            anchor: Anchor.topCenter,
          );

          // If Time's Up
        } else {
          // TODO: MOVE TO update()

          // Stop Playing
          playing = false;
          triggerGameEnd();
          // box.updatePosition(reset: true);
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

        // Your Score
        scoreTextConfig.render(
          canvas,
          score.toString(),
          Position(
            (screenSize.width / 2) - 50,
            (screenSize.height / 2) - 90,
          ),
          anchor: Anchor.center,
        );

        // Separator
        textConfig.render(
          canvas,
          "|",
          Position(
            screenSize.width / 2,
            screenSize.height,
          ),
          anchor: Anchor.center,
        );

        // Opponent Score
        opponentScoreTextConfig.render(
          canvas,
          opponentScore.toString(),
          Position(
            (screenSize.width / 2) + 50,
            (screenSize.height / 2) - 90,
          ),
          anchor: Anchor.center,
        );

        textConfig.render(
          canvas,
          "TAP BOX TO REPLAY",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 + 100,
          ),
          anchor: Anchor.center,
        );
        TextConfig(
          fontSize: 20,
          color: Colors.white,
          textAlign: TextAlign.center,
        ).render(
          (canvas),
          "tap outside to sign out",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 + 130,
          ),
          anchor: Anchor.center,
        );
      }
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
    tileSize = screenSize.height / 9;
  }

  void onTapDown(TapDownDetails details) async {
    if (box.rect.contains(details.globalPosition)) {
      if (!signedIn) {
        print('USER TAPPED TO SIGN IN 🤏🤏🤏🤏🤏🤏🤏🤏');
        UserCredential userCred = await anonymousSignIn();
      } else {
        // Start Game
        if (!started) started = true;

        // Box On Tap Down
        box.onTapDown(details);
      }
    } else {
      if (signedIn) {
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

          // Reset Box Position & Color
          // box.updatePosition(reset: true);
          box.paint.color = Colors.white;

          // Stop Playing
          playing = false;
          triggerGameEnd();
        } else {
          // sign out if tapped outside box while not playing
          await FirebaseAuth.instance.signOut();
        }
      }
    }
  }
}
