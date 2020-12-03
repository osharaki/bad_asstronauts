import 'dart:math';

import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';
import 'package:gameOff2020/utils/var.dart';
import 'package:gameOff2020/utils/math.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:gameOff2020/components/spaceship.dart';

import '../mainGame.dart';

class MyParticle extends BodyComponent {
  final MainGame game;

  Random random = Random();

  Vector2 startPosition;
  Vector2 endPosition;
  Vector2 direction;
  double startSize;
  double endSize;
  Color startColor;
  Color endColor;
  BodyComponent follow;
  double startSpeed;
  double endSpeed;
  double life;
  Rect rect;
  Paint paint;
  Vector2 startPositionRandom;
  Vector2 endPositionRandom;
  Vector2 endPositionOffset;
  Vector2 endPositionOffsetNudge = Vector2.zero();
  Vector2 turbulenceMagnitude;
  double turbulenceSmoothness;

  /// Life (seconds) in frames (60/sec)
  double frames;

  /// To obtain life progress from
  double currentFrame = 0;

  /// Size to apply at current frame
  double currentSize;

  /// 0 to 1 life progress
  double progress = 0;

  Color currentColor;
  Vector2 currentPosition;
  double currentSpeed;

  Vector2 nextTurbulence;
  Vector2 turbulenceNudge = Vector2.zero();

  MyParticle({
    @required this.game,
    @required this.startPosition,
    this.direction,
    this.startSize = 1,
    this.startColor = Colors.white,
    this.follow,
    this.startSpeed = 1,
    this.life = 1,
    this.endSize,
    this.endColor,
    this.endPosition,
    this.endSpeed,
    this.startPositionRandom,
    this.endPositionRandom,
    this.turbulenceMagnitude,
    this.turbulenceSmoothness = 30,
  }) {
    frames = 60 * life;

    // Randomize Start Position
    if (startPositionRandom != null) {
      startPosition += Vector2(
        getRandomValueInRange(
          min: -startPositionRandom.x,
          max: startPositionRandom.x,
        ),
        getRandomValueInRange(
          min: -startPositionRandom.y,
          max: startPositionRandom.y,
        ),
      );
    }

    // Randomize End Position
    if (endPositionRandom != null) {
      endPositionOffset = Vector2(
        getRandomValueInRange(
          min: -endPositionRandom.x,
          max: endPositionRandom.x,
        ),
        getRandomValueInRange(
          min: -endPositionRandom.y,
          max: endPositionRandom.y,
        ),
      );

      endPositionOffsetNudge = endPositionOffset.scaled(1 / frames);

      if (endPosition != null) endPosition += endPositionOffset;
    }

    currentSize = startSize;
    currentColor = startColor;
    currentPosition = startPosition;
    currentSpeed = startSpeed;
    paint = Paint();
    paint.color = currentColor;
    if (turbulenceSmoothness == 0) turbulenceSmoothness = 1;
    if (direction != null) direction = normalizeVector(direction);
  }

  @override
  void update(double dt) {
    super.update(dt);

    progress = currentFrame / frames;

    // Size
    if (endSize != null) {
      currentSize = mapValueFromRangeToRange(
        aValue: progress,
        aStart: 0,
        aEnd: 1,
        bStart: startSize,
        bEnd: endSize,
      );
    }

    // Color
    if (endColor != null) {
      currentColor = blendColors(
        startColor: startColor,
        endColor: endColor,
        blend: progress,
      );
    }

    // Speed
    if (endSpeed != null) {
      currentSpeed = mapValueFromRangeToRange(
        aValue: progress,
        aStart: 0,
        aEnd: 1,
        bStart: startSpeed,
        bEnd: endSpeed,
      );
    }

    // Position
    if (follow != null) {
      Vector2 dir = normalizeVector(follow.body.position - currentPosition);

      // currentPosition =
      //     body.position + endPositionOffsetNudge + dir.scaled(currentSpeed);

      currentPosition = body.position +
          (endPositionOffset * progress) +
          dir.scaled(currentSpeed);
    } else if (direction != null) {
      currentPosition = body.position + direction.scaled(currentSpeed);
    }

    // Turbulence
    if (turbulenceMagnitude != null &&
        currentFrame % turbulenceSmoothness == 0) {
      nextTurbulence = Vector2(
        getRandomValueInRange(
          min: -turbulenceMagnitude.x,
          max: turbulenceMagnitude.x,
        ),
        getRandomValueInRange(
          min: -turbulenceMagnitude.y,
          max: turbulenceMagnitude.y,
        ),
      );

      turbulenceNudge = nextTurbulence.scaled(1 / turbulenceSmoothness);
    }

    currentPosition += turbulenceNudge;

    paint.color = currentColor;
    body.setTransform(currentPosition, 0);

    // Destroy when progress is 1
    if (progress >= 1) {
      destroy();
    } else {
      currentFrame += 1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      convertVectorToOffset(viewport.getWorldToScreen(body.position)),
      currentSize / 2,
      paint,
    );
  }

  void destroy() {
    game.remove(this);
  }

  @override
  Body createBody() {
    CircleShape shape = CircleShape()..radius = startSize / 2;
    final FixtureDef fixtureDef = FixtureDef();
    fixtureDef.shape = shape;

    paint.color = Colors.transparent;

    final bodyDef = BodyDef();
    bodyDef
      ..position = startPosition
      ..type = BodyType.STATIC
      ..setUserData(this);

    return world.createBody(bodyDef)..createFixture(fixtureDef).setSensor(true);
  }
}
