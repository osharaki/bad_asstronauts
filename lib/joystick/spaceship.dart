import 'dart:math';

import 'package:flame/sprite.dart';
import "package:flutter/material.dart";
import "joystickGame.dart";

class Spaceship {
  // Instance Variables
  Rect rect;
  double size;
  Sprite sprite;
  bool move = false;
  double speed = 250;
  double multiplier = 1;
  double aspectRatio = 1;
  final JoystickGame game;
  double lastMoveRadAngle = 0;

  Spaceship({@required this.game}) {
    initialize();
  }

  void initialize() {
    // Obtain Spaceship size from device's Tile Size * Spaceship's Aspect Ratio
    size = game.tileSize * aspectRatio;

    // Create Rect at Screen Center to contain Spaceship
    rect = Rect.fromLTWH(
      (game.screenSize.width / 2) - (size / 2),
      (game.screenSize.height / 2) - (size / 2),
      size,
      size * 2,
    );

    // Create Spaceship Sprite from Images
    sprite = Sprite("spaceship.png");
  }

  void update(double t) {
    // If Joystick sets Spaceship to moving (based on dragging)
    if (move) {
      // Same as getting Drag Radial Position for Joystick, but (multiplier * speed * t) is our radius
      var nextPosition = Offset(
        (multiplier * speed * t) * cos(lastMoveRadAngle),
        (multiplier * speed * t) * sin(lastMoveRadAngle),
      );

      // Spaceship's offset from it's next position
      var difference = Offset(
            rect.center.dx + nextPosition.dx,
            rect.center.dy + nextPosition.dy,
          ) -
          rect.center;

      // Shift Spaceship to it's next position
      rect = rect.shift(difference);
    }
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
}
