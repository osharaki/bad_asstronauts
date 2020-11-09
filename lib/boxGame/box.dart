import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gameOff2020/boxGame/services/services.dart';

import "boxGame.dart";
import "../utils/math.dart";
import "package:flutter/material.dart";
import "package:vibration/vibration.dart";

class Box {
  Rect rect;
  Paint paint;
  Offset position;
  double size = 50;
  final BoxGame game;
  var random = Random();

  Box({@required this.game}) {
    updatePosition(reset: true);

    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size,
      size,
    );

    paint = Paint();

    paint.color = Colors.white;

    // FirebaseFirestore.instance
    //     .collection('game/position')
    //     .snapshots()
    //     .listen((data) => updateRectPos(data));

    paint.color = Color.fromARGB(
      255,
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }

  void update(double t) {
    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size,
      size,
    );
  }

  void updatePosition({bool reset = false}) {
    if (reset) {
      position = Offset(
        (game.screenSize.width / 2) - (size / 2),
        (game.screenSize.height / 2) - (size / 2),
      );
    } else {
      position = Offset(
        getRandomValueInRange(
          min: 0,
          max: (game.screenSize.width - size).toInt(),
        ).toDouble(),
        getRandomValueInRange(
          min: 0,
          max: (game.screenSize.height - size).toInt(),
        ).toDouble(),
      );
    }
  }

  void onTapDown(TapDownDetails details) async {
    // TODO: Update firestore position field every time player taps box
    // updateBoxPos(
    //     screenHeight: (game.screenSize.height).toInt(),
    //     screenWidth: (game.screenSize.width).toInt());
    if (!game.playing) {
      // Start Playing
      game.playing = true;

      // Score
      game.score = 0;

      // Time
      game.timeLimit = 30;
    } else {
      // Score
      game.score += 1;
    }

    // Vibration
    if (await Vibration.hasAmplitudeControl()) {
      Vibration.vibrate(
        duration: 25,
        amplitude: 50,
      );
    } else if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 25);
    }

    updatePosition();
  }

  void updateRectPos(newPos) {
    rect = Rect.fromLTWH(
      newPos.data['posX'],
      newPos.data['posY'],
      newPos.data[size],
      newPos.data[size],
    );
  }
}
