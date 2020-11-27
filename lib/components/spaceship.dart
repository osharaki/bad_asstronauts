import 'dart:math';
import 'dart:ui';

import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/mainGame.dart';

class Spaceship extends BodyComponent implements JoystickListener {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final double speed = 159;
  final double capacity= 100;
  final String id;

  double resources = 100;
  Sprite spaceship;
  double currentSpeed = 0;
  double radAngle = 0;
  bool _move = false;

  Spaceship(this.game, Image image, this.id, {this.size, this.position}) {
    spaceship = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_move) {
      moveFromAngle(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    Vector2 posRect = viewport.getWorldToScreen(body.worldCenter);
    Rect rect =
        Rect.fromCenter(center: Offset(posRect.x, posRect.y), width: size.x, height: size.y);
    canvas.translate(posRect.x, posRect.y);
    canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
    canvas.translate(-posRect.x, -posRect.y);
    spaceship.renderRect(canvas, rect);
    canvas.restore();
  }

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
    paint.color = Colors.transparent;

    final fixtureDef = FixtureDef()..shape = shape;

    final bodyDef = BodyDef()
      ..setUserData(this) // To be able to determine object in collision
      ..position = position
      ..type = BodyType.DYNAMIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
