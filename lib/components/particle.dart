import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/spaceship.dart';
import 'package:gameOff2020/utils/math.dart';

import '../mainGame.dart';

class MyParticle extends BodyComponent {
  final MainGame game;

  Vector2 position;
  Vector2 direction;
  double size;
  double endSize;
  Color color;
  Spaceship follow;
  double speed;
  double life;

  CircleShape shape;
  final FixtureDef fixtureDef = FixtureDef();

  // Life (seconds) in frames (60/sec)
  double frames;

  // To obtain life progress from
  double currentFrame = 0;

  // Size to apply at current frame (WIP)
  double currentSize;

  // 0 to 1 life progress
  double progress = 0;

  MyParticle({
    @required this.game,
    @required this.position,
    @required this.direction,
    this.size = 1,
    this.color = Colors.white,
    this.follow,
    this.speed = 1,
    this.life = 1,
    this.endSize,
  }) {
    shape = CircleShape()..radius = size / 2;
    fixtureDef.shape = shape;

    frames = 60 * life;
    currentSize = size;
  }

  @override
  void update(double dt) {
    super.update(dt);

    progress = currentFrame / frames;

    //TODO: Animate Size over time, if endSize provided. Works in values, but doesn't actually render properly
    if (endSize != null) {
      currentSize = mapValueFromRangeToRange(
        aValue: currentFrame,
        aStart: 0,
        aEnd: frames,
        bStart: size,
        bEnd: endSize,
      );

      // print(currentSize);

      updateSize(currentSize);
    }

    // Destroy when progress if 1
    if (progress >= 1) {
      destroy();
    } else {
      currentFrame += 1;
    }

    // TODO: Implement follow object logic
    if (follow != null) {}
  }

  void destroy() {
    game.remove(this);
  }

  void updateSize(double size) {
    shape = CircleShape()..radius = size / 2;

    fixtureDef.setShape(shape);

    print("SHAPE SIZE: ${fixtureDef.getShape().radius}");
  }

  @override
  Body createBody() {
    paint.color = color;

    final bodyDef = BodyDef();
    bodyDef
      ..position = position
      ..type = BodyType.DYNAMIC
      ..linearVelocity = Vector2(direction.x * speed, direction.y * speed)
      ..setUserData(this);

    return world.createBody(bodyDef)..createFixture(fixtureDef).setSensor(true);
  }
}
