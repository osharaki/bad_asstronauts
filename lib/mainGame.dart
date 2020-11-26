import 'dart:ui';

import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/gestures.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';

import 'components/planet.dart';
import 'components/planetSensor.dart';
import 'components/player.dart';
import 'components/spaceship.dart';

class MainGame extends Forge2DGame with MultiTouchDragDetector {
  Spaceship spaceship;
  Player player;
  Planet planet;
  PlanetSensor planetSensor;

  final joystick = JoystickComponent(
    directional: JoystickDirectional(),
    actions: [
      JoystickAction(
        actionId: 1,
        size: 50,
        margin: const EdgeInsets.all(50),
        color: const Color(0xFF0000FF),
      ),
      JoystickAction(
        actionId: 2,
        size: 50,
        color: const Color(0xFF00FF00),
        margin: const EdgeInsets.only(
          right: 50,
          bottom: 120,
        ),
      ),
      JoystickAction(
        actionId: 3,
        size: 50,
        margin: const EdgeInsets.only(bottom: 50, right: 120),
        enableDirection: true,
      ),
    ],
  );

  MainGame()
      : super(
          gravity: Vector2.zero(),
        ) {
    images.loadAll([
      "spaceship.png",
      "moon.png",
    ]).then((images) {
      planetSensor = PlanetSensor(this, size: Vector2(268, 268), position: Vector2(100, 350));
      planet = Planet(this, images[1], size: Vector2(268, 268), position: Vector2(100, 350));
      player = Player(this);
      spaceship = Spaceship(this, images.first, Vector2(254, 512).scaled(0.06));
      joystick.addObserver(spaceship);
      add(spaceship);
      add(planet);
      add(planetSensor);
      add(joystick);
      add(player);
      add(MyCircle(this,
          10)); // Not passing game.size directly because atthis point, size is still Vector2.zero(). See https://pub.dev/documentation/flame/1.0.0-rc2/game_base_game/BaseGame/size.html})
    });
  }

  @override
  Color backgroundColor() {
    return Colors.blue[900];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (spaceship != null) cameraFollow(spaceship, horizontal: 0, vertical: 0);
  }

  /* void initialize() {
    joystick.addObserver(spaceship);
    // add(spaceship);
    add(joystick);
  } */

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // canvas.drawCircle(Offset(100, 100), 10, Paint()..color = Colors.red);
  }

  /* @override
  Future<void> onLoad() async {
    print('called onload');
    Image spaceshipImage = await images.load('spaceship.png');
    spaceship = Spaceship(Sprite(spaceshipImage), Vector2(25.4, 51.2));
    initialize();
  } */
}

class MyCircle extends BodyComponent {
  final MainGame game;
  final double radius;
  Vector2 position;

  MyCircle(this.game, this.radius) {
    position = Vector2(game.size.x / 2 + 100, game.size.y / 2);
  }

  @override
  Body createBody() {
    final CircleShape shape = CircleShape();
    shape.radius = radius;
    Vector2 worldPosition = Vector2(position.x, position.y);

    final fixtureDef = FixtureDef()
      ..shape = shape
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..setUserData(this)
      ..position = worldPosition
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
