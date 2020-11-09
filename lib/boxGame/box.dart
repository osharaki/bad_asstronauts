import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gameOff2020/boxGame/services/services.dart';

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

    /*firestore.collection('game').get().then((QuerySnapshot querySnapshot) {
      print('!!!!!!!!!!!!!!!!');
      print(querySnapshot);
    }).catchError(() => print('Firestore error!!!!!!!!')); */
    FirebaseFirestore.instance.collection('game').doc('position').snapshots().listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        print('✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️');
        print(documentSnapshot);
      } else {
        print('❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗');
        print('Document does not exits');
      }
      // updatePosition(positionFromServer: data);
    });
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

    // Ensure Box bounds will not be outide of screen
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

    // Set final screen position
    Offset position = Offset(xPosition, yPosition);

    return position;
  }

  // void updatePosition({bool reset = false}) {
  //   if (reset) {
  //     position = Offset(
  //       (game.screenSize.width / 2) - (size / 2),
  //       (game.screenSize.height / 2) - (size / 2),
  //     );
  //   } else {
  //     position = Offset(
  //       getRandomValueInRange(
  //         min: 0,
  //         max: (game.screenSize.width - size).toInt(),
  //       ).toDouble(),
  //       getRandomValueInRange(
  //         min: 0,
  //         max: (game.screenSize.height - size).toInt(),
  //       ).toDouble(),
  //     );
  //   }
  // }

  void updatePosition({bool reset = false, dynamic positionFromServer}) {
    if (reset) {
      // Reset to default center position
      position = center;
    } else {
      // Get Screen position from Percent position
      var positionPercent = getPositionPercent();
      position = convertPercentToPosition(positionPercent);
    }
  }

  void onTapDown(TapDownDetails details) async {
    // Update firestore position field every time player taps box
    triggerBoxPosUpdate(
      screenHeight: (game.screenSize.height).toInt(),
      screenWidth: (game.screenSize.width).toInt(),
    );
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

    // Randomize Position
    updatePosition();

    // Randomize Paint Color
    paint.color = Color.fromARGB(
      255,
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }

  void updateRectPos(newPos) {
    rect = Rect.fromLTWH(
      newPos.data['posX'],
      newPos.data['posY'],
      newPos.data['size'],
      newPos.data['size'],
    );
  }
}
