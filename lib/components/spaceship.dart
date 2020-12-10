import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planet.dart';
import 'package:gameOff2020/mainGame.dart';

class Spaceship extends BodyComponent implements JoystickListener {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final double speed = 159;
  final double capacity = 100;
  final double initRotation;
  final String id;
  final bool isEgo;
  final int crashAnimationCutoff = 3;

  Planet crashPlanet;

  SpriteAnimation crashAnimation;
  int respawnTime = 0;

  double resources = 100;
  double currentSpeed = 0;
  double radAngle;
  double resourceReplenishRate = 0.0005;
  double resourceCriticalThreshold = 6;

  bool _move = false;
  bool inOrbit = false;
  Sprite spaceship;
  Sprite spaceshipInvisible;

  Vector2 posRect;
  Rect rect;
  Spaceship(
      {@required this.game,
      @required Image image,
      @required Image imageInvisible,
      @required this.id,
      this.size,
      this.position,
      this.isEgo = false,
      this.initRotation}) {
    spaceship = Sprite(image);
    spaceshipInvisible = Sprite(imageInvisible);
    crashAnimation =
        SpriteAnimation.spriteList([spaceship, spaceshipInvisible], stepTime: 0.07, loop: true);
    radAngle = initRotation;
  }

  void destroy() {
    game.remove(this);
  }

  set move(bool state) => _move = state;

  @override
  void update(double dt) {
    super.update(dt);
    if (isEgo) {
      if (respawnTime != 0) {
        // E.g. if respawnTime==5 and crashAnimationCutoff==4, this gives us a one second long animation
        if (respawnTime > crashAnimationCutoff)
          crashAnimation.update(dt);
        else if (respawnTime == crashAnimationCutoff)
          game.planetAtmosphereContactCallback.onAtmosphereExit(this, crashPlanet.planetAtmosphere);
        if (body.getType() != BodyType.STATIC) body.setType(BodyType.STATIC);
      } else if (body.getType() != BodyType.DYNAMIC) body.setType(BodyType.DYNAMIC);
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
    if (respawnTime == 0)
      spaceship.renderRect(canvas, rect);
    // E.g. if respawnTime==5 and crashAnimationCutoff==4, this gives us a one second long animation
    else if (respawnTime > crashAnimationCutoff)
      crashAnimation.getSprite().renderRect(canvas, rect);
    canvas.restore();
    // On-board resources should only be displayed either while the ship hasn't crashed or during the animation sequence after a crash
    if (!(0 < respawnTime && respawnTime <= crashAnimationCutoff))
      TextConfig(
        fontSize: 10.0,
        fontFamily: 'Awesome Font',
        textAlign: TextAlign.center,
        color: resources > 20 ? Colors.black : Colors.red,
      ).render(
        canvas,
        resources.toStringAsFixed(1),
        game.viewport
            .getWorldToScreen(Vector2(body.worldCenter.x, body.worldCenter.y + size.y / 2 - 40)),
        anchor: Anchor.center,
      );
  }

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (respawnTime == 0) {
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

    final BodyType bodyType = isEgo ? BodyType.DYNAMIC : BodyType.STATIC;

    final bodyDef = BodyDef()
      ..setUserData(this) // To be able to determine object in collision
      ..position = position
      ..type = bodyType;

    return world.createBody(bodyDef)..createFixture(fixtureDef).setSensor(!isEgo);
  }
}
