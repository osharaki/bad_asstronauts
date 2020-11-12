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

  Offset nextOffset = Offset(0, 0);
  Offset spaceshipOffset = Offset(0, 0);

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
      double multiplier = distance / baseRadius;

      // Next Frame's Offset
      // Same as getting Drag Radial Position, but (multiplier * speed * t) is our radius
      nextOffset = Offset(
        (multiplier * game.spaceship.speed * t) * cos(radAngle),
        (multiplier * game.spaceship.speed * t) * sin(radAngle),
      );

      Offset oldOffset = nextOffset;

      // Limit to World Boundaries
      nextOffset = limitToWorldBoundaries(nextOffset);

      // Get Spaceship Offset
      spaceshipOffset = getSpaceshipOffset(
        oldOffset: oldOffset,
        newOffset: nextOffset,
      );

      spaceshipOffset = limitToScreenBoundaries(spaceshipOffset);

      // Ensure Spaceship returns to Screen Center
      Map<String, bool> isSpaceshipOffset = isSpaceshipOffsetFromCenter();
      Offset spaceshipCenterOffset = getSpaceshipCenterAlignmentOffset();

      if (isSpaceshipOffset["x"])
        spaceshipOffset = Offset(spaceshipCenterOffset.dx, spaceshipOffset.dy);
      if (isSpaceshipOffset["y"])
        spaceshipOffset = Offset(spaceshipOffset.dx, spaceshipCenterOffset.dy);

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
      nextOffset = Offset(0, 0);
      spaceshipOffset = Offset(0, 0);
    }
  }

  Map<String, bool> isSpaceshipOffsetFromCenter() {
    Offset spaceshipScreenCenterOffset =
        game.spaceship.getOffsetFromScreenCenter();

    Map<String, bool> offsetValues = {"x": false, "y": false};

    // X
    if ((spaceshipScreenCenterOffset.dx != 0) && (nextOffset.dx != 0)) {
      offsetValues["x"] = true;
    }

    // Y
    if ((spaceshipScreenCenterOffset.dy != 0) && (nextOffset.dy != 0)) {
      offsetValues["y"] = true;
    }

    return offsetValues;
  }

  Offset getSpaceshipCenterAlignmentOffset() {
    Offset spaceshipScreenCenterOffset =
        game.spaceship.getOffsetFromScreenCenter();

    double xOffsetIncrement = 0;
    double yOffsetIncrement = 0;

    // X
    if ((spaceshipScreenCenterOffset.dx != 0) && (nextOffset.dx != 0)) {
      xOffsetIncrement = spaceshipScreenCenterOffset.dx * -0.1;
    }

    // Y
    if ((spaceshipScreenCenterOffset.dy != 0) && (nextOffset.dy != 0)) {
      yOffsetIncrement = spaceshipScreenCenterOffset.dy * -0.1;
    }

    Offset offsetIncrement = Offset(xOffsetIncrement, yOffsetIncrement);

    return offsetIncrement;
  }

  Offset getSpaceshipOffset({
    @required Offset oldOffset,
    @required Offset newOffset,
  }) {
    double xOffset = 0;
    double yOffset = 0;

    if (newOffset.dx == 0) xOffset = oldOffset.dx;
    if (newOffset.dy == 0) yOffset = oldOffset.dy;

    Offset spaceshipOffset = Offset(xOffset, yOffset);

    return spaceshipOffset;
  }

  Offset limitToScreenBoundaries(Offset offset) {
    // Limit to Screen Boundaries
    if (game.spaceship.exceedsTop(offset.dy)) offset = Offset(offset.dx, 0);

    if (game.spaceship.exceedsBottom(offset.dy)) offset = Offset(offset.dx, 0);

    if (game.spaceship.exceedsLeft(offset.dx)) offset = Offset(0, offset.dy);

    if (game.spaceship.exceedsRight(offset.dx)) offset = Offset(0, offset.dy);

    return offset;
  }

  Offset limitToWorldBoundaries(Offset offset) {
    // Limit to World Boundaries
    if (game.server.world.exceedsTop(offset.dy)) offset = Offset(offset.dx, 0);

    if (game.server.world.exceedsBottom(offset.dy))
      offset = Offset(offset.dx, 0);

    if (game.server.world.exceedsLeft(offset.dx)) offset = Offset(0, offset.dy);

    if (game.server.world.exceedsRight(offset.dx))
      offset = Offset(0, offset.dy);

    return offset;
  }

  void render(Canvas canvas) {
    baseSprite.renderRect(canvas, baseRect);
    knobSprite.renderRect(canvas, knobRect);
  }

  void onPanStart(DragStartDetails details) {
    // If drag starts on Knob
    if (knobRect.contains(details.globalPosition)) {
      dragging = true;
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
    dragPosition = joystickCenter;
  }
}
