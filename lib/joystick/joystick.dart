import 'dart:math';
import 'mainGame.dart';
import 'package:flame/sprite.dart';
import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/touchData.dart';

class Joystick {
  // Instance Variables
  final MainGame game;

  int touchId;

  Offset joystickCenter;
  double offset = 20;

  Rect baseRect;
  double baseRadius;
  Sprite baseSprite;
  double baseOpacity = 0.8;
  Paint basePaint = Paint();
  double baseAspectRatio = 1.4;

  Rect knobRect;
  double knobRadius;
  Sprite knobSprite;
  double knobOpacity = 0.6;
  Paint knobPaint = Paint();
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

    // Paint
    basePaint.color = Color.fromRGBO(
      255,
      255,
      255,
      baseOpacity,
    );

    knobPaint.color = Color.fromRGBO(
      255,
      255,
      255,
      knobOpacity,
    );
  }

  void update(double t) {
    // Drag knob
    if (dragging) {
      // Get Angle (in radians) from Joystick center to Drag position
      double radAngle = atan2(
        dragPosition.dy - joystickCenter.dy,
        dragPosition.dx - joystickCenter.dx,
      );

      // Get distance between Joystick center and Drag position
      var centerPoint = Point(joystickCenter.dx, joystickCenter.dy);
      var dragPoint = Point(dragPosition.dx, dragPosition.dy);
      double distance = centerPoint.distanceTo(dragPoint);

      // Clamp distance max value to Joystick radius, as we can't go outside the joystick bounds
      distance = (distance < baseRadius) ? distance : baseRadius;

      // Use distance as multiplier for spaceship speed
      double multiplier = distance / baseRadius;

      // Use angle to orient spaceship
      game.serverHandler.spaceships[game.id].lastMoveRadAngle = radAngle;

      // Next Frame's Offset
      // Same as getting Drag Radial Position, but (multiplier * speed * t) is our radius
      nextOffset = Offset(
        (multiplier * game.serverHandler.spaceships[game.id].speed * t) *
            cos(radAngle),
        (multiplier * game.serverHandler.spaceships[game.id].speed * t) *
            sin(radAngle),
      );

      Offset oldOffset = nextOffset;

      // Limit to Arena Boundaries
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

      // Obtain Spaceship Arena Position
      game.serverHandler.spaceships[game.id].worldPosition =
          game.serverHandler.spaceships[game.id].getWorldPosition();

      // Send spaceship arena position to serverHandler
      game.serverHandler.spaceships[game.id].sendToServer();
    }
  }

  Map<String, bool> isSpaceshipOffsetFromCenter() {
    Offset spaceshipScreenCenterOffset =
        game.serverHandler.spaceships[game.id].getOffsetFromScreenCenter();

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
        game.serverHandler.spaceships[game.id].getOffsetFromScreenCenter();

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
    if (game.serverHandler.spaceships[game.id].exceedsTop(offset.dy))
      offset = Offset(offset.dx, 0);

    if (game.serverHandler.spaceships[game.id].exceedsBottom(offset.dy))
      offset = Offset(offset.dx, 0);

    if (game.serverHandler.spaceships[game.id].exceedsLeft(offset.dx))
      offset = Offset(0, offset.dy);

    if (game.serverHandler.spaceships[game.id].exceedsRight(offset.dx))
      offset = Offset(0, offset.dy);

    return offset;
  }

  Offset limitToWorldBoundaries(Offset offset) {
    // Limit to Arena Boundaries
    if (game.serverHandler.arena.exceedsTop(offset.dy))
      offset = Offset(offset.dx, 0);

    if (game.serverHandler.arena.exceedsBottom(offset.dy))
      offset = Offset(offset.dx, 0);

    if (game.serverHandler.arena.exceedsLeft(offset.dx))
      offset = Offset(0, offset.dy);

    if (game.serverHandler.arena.exceedsRight(offset.dx))
      offset = Offset(0, offset.dy);

    return offset;
  }

  void render(Canvas canvas) {
    baseSprite.renderRect(canvas, baseRect, overridePaint: basePaint);
    knobSprite.renderRect(canvas, knobRect, overridePaint: knobPaint);
  }

  void onTap(TouchData touch) {
    dragging = true;

    if (touchId == null) touchId = touch.touchId;
  }

  void onDrag(TouchData touch) {
    // Update drag position
    dragPosition = touch.offset;
  }

  void onRelease() {
    // Stop moving Spaceship and return Joystick to center
    touchId = null;
    dragging = false;
    nextOffset = Offset(0, 0);
    dragPosition = joystickCenter;
    spaceshipOffset = Offset(0, 0);
    Offset difference = dragPosition - knobRect.center;
    knobRect = knobRect.shift(difference);
  }
}
