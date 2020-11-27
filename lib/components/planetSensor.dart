import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planet.dart';
import 'package:gameOff2020/mainGame.dart';

import 'spaceship.dart';

// TODO add visual cue to indicate planet harvesting range (see Trello card)
class PlanetSensor extends BodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final PlanetSensorContactCallback contactCallback;
  final Planet planet;

  PlanetSensor(this.game, this.planet, {this.size, this.position})
      : contactCallback = PlanetSensorContactCallback() {
    game.addContactCallback(contactCallback);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (contactCallback.spaceshipsInOrbit.length != 0) {
      for (Spaceship spaceship in contactCallback.spaceshipsInOrbit) {
        spaceship.body.applyForce(
            (body.worldCenter - spaceship.body.worldCenter).scaled(10), spaceship.body.worldCenter);
        if (spaceship.id == planet.spaceshipId) {
          // home planet -> store
          planet.resources += game.storeRate;
          spaceship.resources -= game.storeRate;
        } else {
          // foreign planet -> harvest
          planet.resources -= game.harvestRate;
          spaceship.resources += game.harvestRate;
        }
        // print("player resources: " + spaceship.resources.toString());
      }
      // print("planet resources: " + planet.resources.toString());
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
  List<Spaceship> spaceshipsInOrbit = [];

  @override
  void begin(Spaceship spaceship, PlanetSensor planetSensor, Contact contact) {
    print('spaceship entered atmosphere!');
    spaceshipsInOrbit.add(spaceship);
    print(spaceshipsInOrbit);
  }

  @override
  void end(Spaceship spaceship, PlanetSensor planetSensor, Contact contact) {
    print('spaceship left atmosphere!');
    spaceshipsInOrbit.remove(spaceship);
    print(spaceshipsInOrbit);
  }
}
