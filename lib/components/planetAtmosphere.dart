import 'dart:math';

import 'package:flame/anchor.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/particle.dart';
import 'package:gameOff2020/components/planet.dart';
import 'package:gameOff2020/mainGame.dart';
import 'package:gameOff2020/utils/math.dart';

import 'spaceship.dart';

// TODO add visual cue to indicate planet harvesting range (see Trello card)
class PlanetAtmosphere extends BodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final Planet planet;
  final List<Spaceship> spaceshipsInOrbit = [];

  bool shot = false;

  PlanetAtmosphere({
    @required this.game,
    @required this.planet,
    this.size,
    this.position,
  });

  void destroy() {
    game.remove(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (spaceshipsInOrbit.isNotEmpty) {
      for (Spaceship spaceship in spaceshipsInOrbit) {
        // Using Point allows us to obtain distance from planet
        Point spaceshipPoint = Point(
          spaceship.body.worldCenter.x,
          spaceship.body.worldCenter.y,
        );

        Point planetPoint = Point(
          body.worldCenter.x,
          body.worldCenter.y,
        );

        double distance = planetPoint.distanceTo(spaceshipPoint);

        // Divide by distance squared to get and accurate gravity fallof
        double gravityFalloff = 1 / pow(distance / 100, 2);

        // Remap gravity force to 0 -> 1 range
        double pullForce = mapValueFromRangeToRange(
          aValue: gravityFalloff,
          aStart: 0.15,
          aEnd: 0.45,
          bStart: 0,
          bEnd: 1,
        );

        pullForce = clampValueToRange(
          value: pullForce,
          min: 0,
          max: 1,
        ).toDouble();

        // print(pullForce);

        // Multiplier acts as gravity magnitude
        double gravityMultiplier = 17.5;

        Vector2 pullVector = body.worldCenter - spaceship.body.worldCenter;

        spaceship.body.applyForceToCenter(
          pullVector.scaled(pullForce * gravityMultiplier),
        );

        if (spaceship.id == planet.spaceshipId) {
          // home planet -> store

          // Ensure ship resources never drop below the amount necessary to exit orbit
          if (spaceship.resources > spaceship.resourceCriticalThreshold) {
            double payload =
                min(spaceship.resources, game.storeRate) * pullForce;
            planet.resources += payload;
            spaceship.resources -= payload;
          }
        } else {
          // foreign planet -> harvest

          // Ensure ship's harvest doesn't exceed capacity and planet resources never drop below zero
          double payload = [
                game.harvestRate,
                spaceship.capacity - spaceship.resources,
                planet.resources,
              ].reduce(min) *
              pullForce;
          planet.resources -= payload;
          spaceship.resources += payload;
        }
        // print("Spaceship at ${spaceship.resources.toString()}/${spaceship.capacity} capacity");
      }
      // print("Planet resources: " + planet.resources.toString());
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (spaceshipsInOrbit.isNotEmpty) {
      for (Spaceship spaceship in spaceshipsInOrbit) {
        if (spaceship.isEgo) {
          final particle = MyParticle(
            game: game,
            startPosition: planet.spaceshipId == spaceship.id
                ? spaceship.body.position
                : body.worldCenter,
            follow: planet.spaceshipId == spaceship.id ? this : spaceship,
            life: 0.75,
            startSize: 5,
            endSize: 2.5,
            startSpeed: 6,
            startColor: Colors.yellow,
            endColor: Colors.amberAccent,
            startPositionRandom: planet.spaceshipId == spaceship.id
                ? Vector2(5, 5)
                : Vector2(50, 50),
            endPositionRandom: planet.spaceshipId == spaceship.id
                ? Vector2(250, 250)
                : Vector2(5, 5),
            turbulenceMagnitude: Vector2(15, 15),
            turbulenceSmoothness: 50,
          );

          game.add(particle);
        }
      }
    }
  }

  @override
  Body createBody() {
    final CircleShape shape = CircleShape()
      ..radius = size.x / 2 +
          (size.x *
              0.4); // planet sensor is a certain percentage larger than planet

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

class PlanetAtmosphereContactCallback
    extends ContactCallback<Spaceship, PlanetAtmosphere> {
  @override
  void begin(
      Spaceship spaceship, PlanetAtmosphere planetAtmosphere, Contact contact) {
    // print('spaceship entered atmosphere!');
    planetAtmosphere.spaceshipsInOrbit.add(spaceship);
    spaceship.inOrbit = true;
    // print(planetAtmosphere.spaceshipsInOrbit);
  }

  @override
  void end(
      Spaceship spaceship, PlanetAtmosphere planetAtmosphere, Contact contact) {
    // print('spaceship left atmosphere!');
    planetAtmosphere.spaceshipsInOrbit.remove(spaceship);
    spaceship.inOrbit = false;
    // print(planetAtmosphere.spaceshipsInOrbit);
  }
}
