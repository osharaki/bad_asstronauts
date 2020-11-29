import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/mainGame.dart';

class Spaceship extends BodyComponent implements JoystickListener {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final double speed = 159;
  final double capacity = 100;
  final String id;

  double resources = 100;
  double currentSpeed = 0;
  double radAngle = 0;
  double resourceReplenishRate = 0.005;
  double resourceCriticalThreshold = 6;

  bool _move = false;
  bool inOrbit = false;
  Sprite spaceship;

  Spaceship(this.game, Image image, this.id, {this.size, this.position}) {
    spaceship = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_move) {
      moveFromAngle(dt);

      // Consume resources by moving
      // We normalize currentSpeed (turn into a value between 0 and 1) by dividing it by its maximum possible value
      if (!inOrbit) resources -= min(resources, (currentSpeed / 159) / 10);
    }
    // Resources only start being replenished if they drop below critical levels otherwise home planets would have an endless supply of resources, draining the ship as soon as it replenishes its resources and the ship will be stuck. On the planet side of things, The fact that home planets only drain when their ship's resources exceed this critical threshold also ensures that a ship's resources below the threshold act solely as an emergency backup to allow the ship to escape orbit.
    if (resources < resourceCriticalThreshold) {
      resources += [
        resourceReplenishRate,
        resourceCriticalThreshold - resources,
      ].reduce(min);
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

    TextConfig(
      fontSize: 10.0,
      fontFamily: 'Awesome Font',
      textAlign: TextAlign.center,
      color: resources > 20 ? Colors.black : Colors.red,
    ).render(
      canvas,
      resources.toStringAsFixed(2),
      game.viewport
          .getWorldToScreen(Vector2(body.worldCenter.x, body.worldCenter.y + size.y / 2 - 40)),
      anchor: Anchor.center,
    );
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    // TODO: implement joystickChangeDirectional
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    // If check is > 0, it will always and the ship will never stop moving as it is constantly replenishing and its fuel never actually reaches 0
    if (resources > 0.1) {
      _move = event.directional != JoystickMoveDirectional.IDLE;
      if (_move) {
        radAngle = event.radAngle;
        currentSpeed = speed * event.intensity;
      }
    } else
      _move = false;
  }

  void moveFromAngle(double dtUpdate) {
    final double nextX = (currentSpeed * dtUpdate) * cos(radAngle);
    final double nextY = (currentSpeed * dtUpdate) * sin(radAngle);

    // This inversion is necessary because Forge2D uses the normal cartesian coordinate system while Flame uses 0,0 as top-left of screen
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
