import 'dart:math';

import 'package:flame/sprite.dart';
import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/debris.dart';
import "joystickGame.dart";

class Spaceship {
  // Instance Variables
  final JoystickGame game;

  Rect rect;
  double size;
  Sprite sprite;
  int fuelLeft = 10;
  bool move = false;
  double speed = 500;
  Offset worldPosition;
  double multiplier = 1;
  double sizeMultiplier = 1;
  double lastMoveRadAngle = 0;

  Spaceship({@required this.game}) {
    initialize();
  }

  void initialize() {
    // Obtain Spaceship size from device's Tile Size * Spaceship's Aspect Ratio
    size = game.tileSize * sizeMultiplier;

    // Create Rect at Screen Center to contain Spaceship
    rect = Rect.fromLTWH(
      (game.screenSize.width / 2) - (size / 2),
      (game.screenSize.height / 2) - (size),
      size,
      size * 2,
    );

    // Create Spaceship Sprite from Images
    sprite = Sprite("spaceship.png");
  }

  void update(double t) {
    // Debris Impact
    List<int> removeDebris = [];

    for (int i = 0; i < game.server.debris.length; i++) {
      if (rect.overlaps(game.server.debris[i].rect)) {
        fuelLeft -= 1;
        removeDebris.add(i);
      }
    }

    removeDebris.forEach((i) {
      game.server.debris.removeAt(i);
    });

    // Spaceship's offset from it's next position
    var difference = Offset(
      game.joystick.spaceshipOffset.dx,
      game.joystick.spaceshipOffset.dy,
    );

    // Shift Spaceship to it's next position
    rect = rect.shift(difference);
  }

  // Honestly, I don't fully understand what's going on here
  void render(Canvas canvas) {
    // Save Original Rect
    canvas.save();

    // Translate Rect to new position
    canvas.translate(
      rect.center.dx,
      rect.center.dy,
    );

    // Rotate by Joystick angle, then offset by 90 degrees (1.57 radians), because radian starts East, and our Image is facing North
    canvas.rotate(
      (lastMoveRadAngle == 0) ? 0 : lastMoveRadAngle + (pi / 2),
    );

    // Return Rect to previous position
    canvas.translate(
      -rect.center.dx,
      -rect.center.dy,
    );

    // Render Sprite
    sprite.renderRect(canvas, rect);

    // Restore Original Rect
    canvas.restore();
  }

  Offset updateSpaceshipWorldPosition() {
    // Get Spaceship World Position
    worldPosition = game.server.world.rect.topLeft + rect.center;

    // Replace position
    game.serverData["players"][game.id]["spaceship"]["position"] = [
      worldPosition.dx,
      worldPosition.dy,
    ];

    game.sendMessageToServer(
      action: "update",
      data: game.serverData,
    );

    print("WORLD POS: $worldPosition");
  }

  void setSpaceshipWorldPosition(Offset position) {
    worldPosition = position;

    rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size,
      size * 2,
    );
  }

  Offset getOffsetFromScreenCenter() {
    Offset screenCenter = Offset(
      game.screenSize.width / 2,
      game.screenSize.height / 2,
    );

    Offset offset = rect.center - screenCenter;

    return offset;
  }

  bool exceedsTop(double offset) {
    if ((rect.top + offset) < 0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsBottom(double offset) {
    if ((rect.bottom + offset) > (game.screenSize.height)) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsLeft(double offset) {
    if ((rect.left + offset) < 0) {
      return true;
    } else {
      return false;
    }
  }

  bool exceedsRight(double offset) {
    if ((rect.right + offset) > (game.screenSize.width)) {
      return true;
    } else {
      return false;
    }
  }
}
