import 'dart:math';
import 'package:flame/sprite.dart';
import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';

class Enemy {
  // Instance Variables
  JoystickGame game;

  Rect rect;
  Sprite sprite;

  double size;
  double sizeMultiplier = 0.7;

  double angle = 0;
  List<dynamic> position = [0, 0];

  Enemy({@required this.game}) {
    initialize();
  }

  void initialize() {
    // Obtain Spaceship size from device's Tile Size * Spaceship's Aspect Ratio
    size = game.tileSize * sizeMultiplier;

    // Create Rect at Screen Center to contain Spaceship
    rect = Rect.fromLTWH(
      position[0] - (size / 2),
      position[1] - (size),
      size,
      size * 2,
    );

    // Create Spaceship Sprite from Images
    sprite = Sprite("spaceship.png");
  }

  void update(double t) {
    // Create Enemy at world position
    rect = Rect.fromLTWH(
      position[0] - (size / 2) + game.server.world.rect.topLeft.dx,
      position[1] - (size) + game.server.world.rect.topLeft.dy,
      size,
      size * 2,
    );

    // Debris' offset from it's next position
    var difference = Offset(
          rect.center.dx - game.joystick.nextOffset.dx,
          rect.center.dy - game.joystick.nextOffset.dy,
        ) -
        rect.center;

    // Shift Debris to it's next position
    // rect = rect.shift(difference);
  }

  void render(Canvas canvas) {
    // Save Original Rect
    canvas.save();

    // Center rect on canvas
    canvas.translate(
      rect.center.dx,
      rect.center.dy,
    );

    // Rotate canvas
    canvas.rotate(
      (angle == 0) ? 0 : angle + (pi / 2),
    );

    // Return rect's top left corner to canvas center
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
