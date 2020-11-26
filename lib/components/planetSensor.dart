import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/mainGame.dart';

import 'spaceship.dart';

// TODO add visual cue to indicate planet harvesting range (see Trello card)
class PlanetSensor extends BodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final PlanetSensorContactCallback contactCallback;

  PlanetSensor(this.game, {this.size, this.position})
      : contactCallback = PlanetSensorContactCallback() {
    game.addContactCallback(contactCallback);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (contactCallback.applyGravity) {
      Body spaceshipBody = contactCallback.spaceship.body;
      spaceshipBody.applyForce(
          (body.worldCenter - spaceshipBody.worldCenter).scaled(10), spaceshipBody.worldCenter);
    }
  }

  @override
  Body createBody() {
    final CircleShape shape = CircleShape()
      ..radius =
          size.x / 2 + (size.x * 0.4); // planet sensor is a certain percentage larger than planet

    final fixtureDef = FixtureDef()..shape = shape;

    paint
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bodyDef = BodyDef()
      ..setUserData(this) // To be able to determine object in collision
      ..position = position
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef).setSensor(true);
  }
}

class PlanetSensorContactCallback extends ContactCallback<Spaceship, PlanetSensor> {
  bool applyGravity = false;
  Spaceship spaceship;

  @override
  void begin(Spaceship spaceship, PlanetSensor planetSensor, Contact contact) {
    print('spaceship entered atmosphere!');
    this.spaceship = spaceship;
    applyGravity = true;
  }

  @override
  void end(Spaceship a, PlanetSensor b, Contact contact) {
    print('spaceship left atmosphere!');
    spaceship = null;
    applyGravity = false;
  }
}
