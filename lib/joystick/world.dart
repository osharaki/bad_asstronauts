import "package:flutter/material.dart";

import 'joystickGame.dart';

class World {
  // Instance Variables
  JoystickGame game;

  Rect rect;
  Paint paint = Paint();

  // Limits
  double topLimit = 0;
  double bottomLimit = 2500;
  double leftLimit = 0;
  double rightLimit = 2500;

  World({this.game}) {
    rect = Rect.fromLTWH(leftLimit, topLimit, rightLimit, bottomLimit);

    paint.color = Colors.indigo[900];
  }

  void update(double t) {
    // Spaceship's offset from it's next position
    var difference = Offset(
          rect.center.dx - game.joystick.nextOffset.dx,
          rect.center.dy - game.joystick.nextOffset.dy,
        ) -
        rect.center;

    // Shift Spaceship to it's next position
    rect = rect.shift(difference);
  }

  void render(Canvas canvas) {
    // Render Rect
    canvas.drawRect(rect, paint);
  }

  bool exceedsTop(double offset) {
    if ((rect.top - offset) > topLimit) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsBottom(double offset) {
    if ((rect.bottom - offset) < (game.screenSize.height)) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsLeft(double offset) {
    if ((rect.left - offset) > leftLimit) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsRight(double offset) {
    if ((rect.right - offset) < (game.screenSize.width)) {
      return true;
    } else {
      return false;
    }
  }
}
