import 'dart:math';
import 'dart:ui';

import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/mainGame.dart';

class Spaceship extends SpriteBodyComponent implements JoystickListener {
  final MainGame game;
  final Vector2 position;
  final double speed = 159;
  double currentSpeed = 0;
  double radAngle = 0;
  bool _move = false;

  Spaceship(this.game, Image image, Vector2 size)
      : position = game.size.scaled(0.4),
        super(Sprite(image), size);

  @override
  void joystickAction(JoystickActionEvent event) {
    // TODO: implement joystickChangeDirectional
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _move = event.directional != JoystickMoveDirectional.IDLE;
    if (_move) {
      radAngle = event.radAngle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    final double nextX = (currentSpeed * dtUpdate) * cos(radAngle);
    final double nextY = (currentSpeed * dtUpdate) * sin(radAngle);

    // TODO figure out why this inversion is even necessary
    body.applyLinearImpulse(Vector2(nextX, -nextY).scaled(20), body.worldCenter, true);
  }

  @override
  Body createBody() {
    // TODO body needs to come to a stop more quickly
    final PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(size.x / 2, size.y / 2);
    paint.color=Colors.green;

    final fixtureDef = FixtureDef()..shape = shape;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..setUserData(this)
      ..position = position
      ..type = BodyType.DYNAMIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
