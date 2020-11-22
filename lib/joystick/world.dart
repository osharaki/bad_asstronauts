import "package:flutter/material.dart";

import 'joystickGame.dart';

class World {
  // Instance Variables
  JoystickGame game;

  Rect rect;
  Paint paint = Paint();

  // Limits
  Size size;
  double sizeMultiplier = 4;

  World({this.game}) {
    size = Size(
      game.screenSize.width * sizeMultiplier,
      game.screenSize.height * sizeMultiplier,
    );

    rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

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
    if ((rect.top -
            offset -
            game.server.spaceships[game.id].getOffsetFromScreenCenter().dy) >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsBottom(double offset) {
    if ((rect.bottom -
            offset -
            game.server.spaceships[game.id].getOffsetFromScreenCenter().dy) <
        (game.screenSize.height)) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsLeft(double offset) {
    if ((rect.left -
            offset -
            game.server.spaceships[game.id].getOffsetFromScreenCenter().dx) >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsRight(double offset) {
    if ((rect.right -
            offset -
            game.server.spaceships[game.id].getOffsetFromScreenCenter().dx) <
        (game.screenSize.width)) {
      return true;
    } else {
      return false;
    }
  }
}
