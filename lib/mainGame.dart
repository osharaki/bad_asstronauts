import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/player.dart';
import 'package:gameOff2020/spaceship.dart';

class MainGame extends Forge2DGame with MultiTouchDragDetector {
  Spaceship spaceship;
  Player player;

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
      "joystickKnob.png",
      "joystickBase.png",
    ]).then((images) {
      player = Player(this);
      spaceship = Spaceship(this, images.first, Vector2(254, 512).scaled(0.2));
      joystick.addObserver(spaceship);
      add(spaceship);
      add(joystick);
      add(player);
      add(MyCircle(this,
      10)); // Not passing game.size directly because atthis point, size is still Vector2.zero(). See https://pub.dev/documentation/flame/1.0.0-rc2/game_base_game/BaseGame/size.html})
    });
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
