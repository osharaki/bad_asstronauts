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
import 'package:gameOff2020/components/particle.dart';
import 'package:gameOff2020/components/planet.dart';
import 'package:gameOff2020/mainGame.dart';
import 'package:gameOff2020/utils/var.dart';

class Spaceship extends BodyComponent implements JoystickListener {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final double speed = 159;
  final double capacity = 100;
  final String id;
  final bool isEgo;

  double resources = 100;
  double currentSpeed = 0;
  double radAngle = 0;
  double resourceReplenishRate = 0.005;
  double resourceCriticalThreshold = 6;
  Vector2 velocity = Vector2.zero();

  bool isSpectating = false;
  bool _move = false;
  bool inOrbit = false;
  Sprite spaceship;

  Vector2 posRect;
  Rect rect;

  Spaceship({
    @required this.game,
    @required Image image,
    @required this.id,
    this.size,
    this.position,
    this.isEgo = false,
  }) {
    spaceship = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isEgo) {
      if (_move) {
        // This inversion is necessary because Forge2D uses the normal cartesian coordinate system while Flame uses 0,0 as top-left of screen
        velocity = Vector2(
          (currentSpeed * dt) * cos(radAngle),
          -(currentSpeed * dt) * sin(radAngle),
        );

        moveSpaceship(velocity);

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

      posRect = viewport.getWorldToScreen(body.worldCenter);
      rect = Rect.fromCenter(
        center: Offset(posRect.x, posRect.y),
        width: size.x,
        height: size.y,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isEgo && _move) {
      final fireParticle = MyParticle(
        game: game,
        startPosition: body.worldCenter,
        direction: velocity.scaled(-1),
        life: 0.25,
        startSize: 5,
        startSpeed: 1,
        endSize: 1,
        startColor: Colors.amber[100],
        endColor: Colors.amber[800],
        startPositionRandom: Vector2(1, 1),
      );

      final smokeParticle = MyParticle(
        game: game,
        startPosition: body.worldCenter,
        direction: velocity.scaled(-1),
        life: 0.75,
        startSize: 5,
        startSpeed: 1,
        endSize: 3,
        startColor: Colors.grey[600],
        endColor: Colors.grey[800],
        startPositionRandom: Vector2(5, 5),
        turbulenceMagnitude: Vector2(25, 25),
        turbulenceSmoothness: 60,
      );

      game.add(smokeParticle);
      game.add(fireParticle);
    }

    posRect = viewport.getWorldToScreen(body.worldCenter);
    rect = Rect.fromCenter(
      center: Offset(posRect.x, posRect.y),
      width: size.x,
      height: size.y,
    );

    canvas.save();
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
      game.viewport.getWorldToScreen(
          Vector2(body.worldCenter.x, body.worldCenter.y + size.y / 2 - 40)),
      anchor: Anchor.center,
    );
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    // TODO: implement joystickChangeDirectional
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    // If check is > 0, it will always pass and the ship will never stop moving as it is constantly replenishing and its fuel never actually reaches 0
    if (resources > 0.1) {
      _move = event.directional != JoystickMoveDirectional.IDLE;
      if (_move) {
        radAngle = event.radAngle;
        currentSpeed = speed * event.intensity;
      }
    } else
      _move = false;
  }

  void moveSpaceship(Vector2 velocity) async {
    body.applyLinearImpulse(
      Vector2(velocity.x, velocity.y).scaled(20),
      body.worldCenter,
      true,
    );
  }

  void destroy() {
    game.remove(this);
  }

  @override
  Body createBody() {
    // TODO body needs to come to a stop more quickly
    final PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(size.x / 2, size.y / 2);
    paint.color = Colors.transparent;

    final fixtureDef = FixtureDef()..shape = shape;

    final BodyType bodyType = isEgo ? BodyType.DYNAMIC : BodyType.STATIC;

    final bodyDef = BodyDef()
      ..setUserData(this) // To be able to determine object in collision
      ..position = position
      ..type = bodyType;

    return world.createBody(bodyDef)
      ..createFixture(fixtureDef).setSensor(!isEgo);
  }
}
