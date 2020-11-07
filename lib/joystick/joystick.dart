import 'dart:math';

import 'package:flame/sprite.dart';
import "package:flutter/material.dart";
import "joystickGame.dart";

class Joystick {
  // Instance Variables
  final JoystickGame game;

  Offset joystickCenter;
  double offset = 20;

  Rect baseRect;
  double baseRadius;
  Sprite baseSprite;
  double baseAspectRatio = 1.4;

  Rect knobRect;
  double knobRadius;
  Sprite knobSprite;
  double knobAspectRatio = 1;

  bool dragging = false;
  Offset dragPosition;

  Joystick({@required this.game}) {
    initialize();
  }

  void initialize() {
    // Create Sprites from Images
    baseSprite = Sprite("joystickBase.png");
    knobSprite = Sprite("joystickKnob.png");

    // Get Joystick elements radii
    baseRadius = (game.tileSize * baseAspectRatio);
    knobRadius = (game.tileSize * knobAspectRatio);

    // Joystick Center for getting drag distance, and rest position
    joystickCenter = Offset(
      baseRadius + offset,
      game.screenSize.height - baseRadius - offset,
    );

    // Joystick Rects
    baseRect = Rect.fromCircle(
      center: joystickCenter,
      radius: baseRadius,
    );

    knobRect = Rect.fromCircle(
      center: joystickCenter,
      radius: knobRadius,
    );

    // Rest Position
    dragPosition = joystickCenter;
  }

  void update(double t) {
    if (dragging) {
      // Get Angle (in radians) from Joystick center to Drag position
      double radAngle = atan2(
        dragPosition.dy - joystickCenter.dy,
        dragPosition.dx - joystickCenter.dx,
      );

      // Use angle to orient spaceship
      game.spaceship.lastMoveRadAngle = radAngle;

      // Get distance between Joystick center and Drag position
      var centerPoint = Point(joystickCenter.dx, joystickCenter.dy);
      var dragPoint = Point(dragPosition.dx, dragPosition.dy);
      double distance = centerPoint.distanceTo(dragPoint);

      // Clamp distance max value to Joystick radius, as we can't go outside the bounds
      distance = (distance < baseRadius) ? distance : baseRadius;

      // Use distance as multiplier for spaceship speed
      game.spaceship.multiplier = distance / baseRadius;

      // Position on Joystick circle, to prevent knob from going outside bounds
      var knobRadialPosition = Offset(
        distance * cos(radAngle),
        distance * sin(radAngle),
      );

      // Knob's offset from Joystick center
      var difference = Offset(
            joystickCenter.dx + knobRadialPosition.dx,
            joystickCenter.dy + knobRadialPosition.dy,
          ) -
          knobRect.center;

      // Shift Knob by offset
      knobRect = knobRect.shift(difference);
    } else {
      // Shift Knob to Joystick center
      Offset difference = dragPosition - knobRect.center;
      knobRect = knobRect.shift(difference);
    }
  }

  void render(Canvas canvas) {
    baseSprite.renderRect(canvas, baseRect);
    knobSprite.renderRect(canvas, knobRect);
  }

  void onPanStart(DragStartDetails details) {
    // If drag starts on Knob
    if (knobRect.contains(details.globalPosition)) {
      dragging = true;
      game.spaceship.move = true;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Update drag position
    if (dragging) {
      dragPosition = details.globalPosition;
    }
  }

  void onPanEnd(DragEndDetails details) {
    // Stop moving Spaceship and return Joystick to center
    dragging = false;
    game.spaceship.move = false;
    dragPosition = joystickCenter;
  }
}
