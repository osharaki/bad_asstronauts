import 'dart:math';

import 'package:flame/anchor.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planet.dart';
import 'package:gameOff2020/mainGame.dart';

import 'spaceship.dart';

// TODO add visual cue to indicate planet harvesting range (see Trello card)
class PlanetAtmosphere extends BodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final Planet planet;
  final List<Spaceship> spaceshipsInOrbit = [];

  final double rateMultiplier = 5;

  PlanetAtmosphere({
    @required this.game,
    @required this.planet,
    this.size,
    this.position,
  });

  /* @override
  void render(Canvas c) {
    super.render(c);
    TextConfig(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      textAlign: TextAlign.center,
    ).render(
      c,
      'Resouuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuurces',
      game.viewport.getWorldToScreen(position),
      anchor: Anchor.center,
    );
  } */

  void destroy() {
    game.remove(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (spaceshipsInOrbit.isNotEmpty) {
      for (Spaceship spaceship in spaceshipsInOrbit) {
        spaceship.body.applyForce(
            (body.worldCenter - spaceship.body.worldCenter).scaled(10), spaceship.body.worldCenter);

        if (spaceship.id == planet.spaceshipId) {
          // home planet -> store

          // If ship hasn't crashed, ensure on-board resources never drop below the amount necessary to exit orbit
          if (spaceship.resources > spaceship.resourceCriticalThreshold ||
              spaceship.respawnTime != 0) {
            double payload = min(spaceship.resources,
                game.storeRate * (spaceship.respawnTime == 0 ? 1.0 : rateMultiplier));
            planet.resources += payload;
            spaceship.resources -= payload;
          }
        } else {
          // foreign planet -> harvest

          // Ensure ship's harvest doesn't exceed capacity and planet resources never drop below zero
          double payload = [
            game.harvestRate * (spaceship.respawnTime == 0 ? 1.0 : rateMultiplier),
            spaceship.capacity - spaceship.resources,
            planet.resources,
          ].reduce(min);
          planet.resources -= payload;
          spaceship.resources += payload;
        }
        // print("Spaceship at ${spaceship.resources.toString()}/${spaceship.capacity} capacity");
      }
      // print("Planet resources: " + planet.resources.toString());
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

class PlanetAtmosphereContactCallback extends ContactCallback<Spaceship, PlanetAtmosphere> {
  @override
  void begin(Spaceship spaceship, PlanetAtmosphere planetAtmosphere, Contact contact) {
    onAtmosphereEnter(spaceship, planetAtmosphere);
  }

  @override
  void end(Spaceship spaceship, PlanetAtmosphere planetAtmosphere, Contact contact) {
    // Prevent immediate contact destruction when ship crashes. In that case, we call onAtmosphereExit() later manually in Spacehip.update()
    if (spaceship.respawnTime == 0) onAtmosphereExit(spaceship, planetAtmosphere);
  }

  void onAtmosphereEnter(Spaceship spaceship, PlanetAtmosphere planetAtmosphere) {
    planetAtmosphere.spaceshipsInOrbit.add(spaceship);
    spaceship.inOrbit = true;
  }

  void onAtmosphereExit(Spaceship spaceship, PlanetAtmosphere planetAtmosphere) {
    planetAtmosphere.spaceshipsInOrbit.remove(spaceship);
    spaceship.inOrbit = false;
  }
}
