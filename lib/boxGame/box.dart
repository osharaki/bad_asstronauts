import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gameOff2020/boxGame/services/functions.dart';

import "boxGame.dart";
import "../utils/math.dart";
import "package:flutter/material.dart";
import "package:vibration/vibration.dart";

class Box {
  final BoxGame game;

  Rect rect;
  Paint paint = Paint();

  double size;
  Offset center;
  Offset position;
  double widthRatio;
  double heightRatio;
  double sizeMultiplier = 1;

  var random = Random();

  Box({@required this.game}) {
    // Derive box size from screen tile size
    size = game.tileSize * sizeMultiplier;
    // Get box center position (default)
    center = Offset(
      (game.screenSize.width / 2) - (size / 2),
      (game.screenSize.height / 2) - (size / 2),
    );

    // Get Width & Height percentage of screen
    widthRatio = (size / game.screenSize.width) * 100;
    heightRatio = (size / game.screenSize.height) * 100;

    // Set position to center position
    position = center;

    // Set Rect from Position & Size
    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size,
      size,
    );

    // Set Default Paint Color
    paint.color = Colors.white;

    /* FirebaseFirestore.instance
        .collection('box')
        .doc('position')
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) updatePosition(positionFromServer: documentSnapshot.data());
    }); */
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }

  void update(double t) {
    rect = Rect.fromLTWH(position.dx, position.dy, size, size);
  }

  Offset getPositionPercent() {
    // Get Random Width & Height between 0% - 100%
    var randomWidthPercent = getRandomValueInRange(
      min: 0,
      max: 100,
    ).toDouble();

    var randomHeightPercent = getRandomValueInRange(
      min: 0,
      max: 100,
    ).toDouble();

    // Ensure Box bounds will not be outside of screen
    if ((randomWidthPercent + widthRatio) > 100) randomWidthPercent -= widthRatio;

    if ((randomHeightPercent + heightRatio) > 100) randomHeightPercent -= heightRatio;

    // Set final percent position
    Offset positionPercent = Offset(randomWidthPercent, randomHeightPercent);

    return positionPercent;
  }

  Offset convertPercentToPosition(Offset positionPercent) {
    // Get screen position from percentage
    double xPosition = getValueInRangeFromPercent(
      min: 0,
      max: game.screenSize.width,
      percent: positionPercent.dx,
    );

    double yPosition = getValueInRangeFromPercent(
      min: 0,
      max: game.screenSize.height,
      percent: positionPercent.dy,
    );

    // Ensure Box bounds will not be outside of screen
    if ((xPosition + size) > 100) xPosition -= size;

    if ((yPosition + size) > 100) yPosition -= size;

    // Set final screen position
    Offset position = Offset(xPosition, yPosition);

    return position;
  }

  void updatePosition({dynamic positionFromServer}) {
    // Get Screen position from Percent position
    /* var positionPercent = getPositionPercent();
      position = convertPercentToPosition(positionPercent); */
    if (positionFromServer['posX'].toDouble() == 50 && positionFromServer['posY'].toDouble() == 50)
      position = center;
    else
      position = convertPercentToPosition(
          Offset(positionFromServer['posX'].toDouble(), positionFromServer['posY'].toDouble()));
  }

  void onTapDown(TapDownDetails details) async {
    if (!game.playing) {
      // Start Playing
      // game.playing = true;
      // Score
      // game.score = 0;

      // Time
      // game.timeLimit = 30;
    } else {
      // Score
      // game.score += 1;
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

    // Randomize Paint Color
    paint.color = Color.fromARGB(
      255,
      255,
      255,
      255,
    );
  }
}
