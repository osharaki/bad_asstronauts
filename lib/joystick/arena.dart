import "package:flutter/material.dart";

import 'mainGame.dart';

class Arena {
  // Instance Variables
  MainGame game;

  Rect rect;
  Paint paint = Paint();

  Offset position = Offset(0, 0);

  // Limits
  Size size;
  double sizeMultiplier = 4;

  Arena({this.game}) {
    size = Size(
      game.screenSize.width * sizeMultiplier,
      game.screenSize.height * sizeMultiplier,
    );

    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
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

    position += difference;

    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
  }

  void render(Canvas canvas) {
    // Render Rect
    canvas.drawRect(rect, paint);
  }

  bool exceedsTop(double offset) {
    if ((rect.top -
            offset -
            game.serverHandler.players[game.id]["spaceship"]
                .getOffsetFromScreenCenter()
                .dy) >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsBottom(double offset) {
    if ((rect.bottom -
            offset -
            game.serverHandler.players[game.id]["spaceship"]
                .getOffsetFromScreenCenter()
                .dy) <
        (game.screenSize.height)) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsLeft(double offset) {
    if ((rect.left -
            offset -
            game.serverHandler.players[game.id]["spaceship"]
                .getOffsetFromScreenCenter()
                .dx) >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsRight(double offset) {
    if ((rect.right -
            offset -
            game.serverHandler.players[game.id]["spaceship"]
                .getOffsetFromScreenCenter()
                .dx) <
        (game.screenSize.width)) {
      return true;
    } else {
      return false;
    }
  }
}
