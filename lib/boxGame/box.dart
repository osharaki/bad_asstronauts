import 'dart:math';

import "boxGame.dart";
import "../utils/math.dart";
import "package:flutter/material.dart";

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
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }

  void update(double t) {
    rect = Rect.fromLTWH(position.dx, position.dy, size, size);
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

  void updatePosition(dynamic newPosition) {
    // Get Screen position from Percent position
    if (newPosition['posX'].toDouble() == 50 && newPosition['posY'].toDouble() == 50)
      position = center;
    else
      position = convertPercentToPosition(
          Offset(newPosition['posX'].toDouble(), newPosition['posY'].toDouble()));
  }
}
