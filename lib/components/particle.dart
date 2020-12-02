import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/spaceship.dart';
import 'package:gameOff2020/utils/math.dart';
import 'package:gameOff2020/utils/var.dart';

import '../mainGame.dart';

class MyParticle extends BodyComponent {
  final MainGame game;

  Vector2 startPosition;
  Vector2 endPosition;
  Vector2 direction;
  double startSize;
  double endSize;
  Color startColor;
  Color endColor;
  Spaceship follow;
  double speed;
  double life;
  Rect rect;
  Paint paint = Paint();

  // Life (seconds) in frames (60/sec)
  double frames;

  // To obtain life progress from
  double currentFrame = 0;

  // Size to apply at current frame (WIP)
  double currentSize;

  // 0 to 1 life progress
  double progress = 0;

  Color currentColor;
  Vector2 currentPosition;

  MyParticle({
    @required this.game,
    @required this.startPosition,
    this.direction,
    this.startSize = 1,
    this.startColor = Colors.white,
    this.follow,
    this.speed = 1,
    this.life = 1,
    this.endSize,
    this.endColor,
    this.endPosition,
  }) {
    frames = 60 * life;
    currentSize = startSize;
    currentColor = startColor;
    currentPosition = startPosition;

    if (direction == null) {
      direction = Vector2.zero();
    } else {
      direction = normalizeVector(direction);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    progress = currentFrame / frames;

    if (endSize != null) {
      currentSize = mapValueFromRangeToRange(
        aValue: currentFrame,
        aStart: 0,
        aEnd: frames,
        bStart: startSize,
        bEnd: endSize,
      );
    }

    if (endColor != null) {
      currentColor = blendColors(
        startColor: startColor,
        endColor: endColor,
        blend: progress,
      );
    }

    // Destroy when progress if 1
    if (progress >= 1) {
      destroy();
    } else {
      currentFrame += 1;
    }

    paint = Paint()..color = currentColor;

    // TODO: Create particle motion randomness
    // TODO: Add acceleration/deceleration
    // TODO: Create initial position randomness buffer
    // TODO: Figure out why particles come flying from bottom center and left center to follow object
    if (follow != null) {
      Vector2 dir = follow.body.position - currentPosition;
      currentPosition = body.position + normalizeVector(dir).scaled(speed);
    } else {
      currentPosition =
          body.position + Vector2(direction.x, direction.y).scaled(speed);
    }

    body.setTransform(currentPosition, 0);
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
      ..type = BodyType.DYNAMIC
      ..setUserData(this);

    return world.createBody(bodyDef)..createFixture(fixtureDef).setSensor(true);
  }
}
