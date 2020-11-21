import 'package:flutter/material.dart';

import 'world.dart';
import 'bullet.dart';
import 'debris.dart';
import 'planet.dart';
import 'asteroid.dart';
import 'spaceship.dart';

import 'joystickGame.dart';

class Server {
  JoystickGame game;

  World world;
  Map<String, Spaceship> spaceships = {};
  List<Debris> debris = List.empty(growable: true);
  List<Planet> planets = List.empty(growable: true);
  List<Asteroid> asteroids = List.empty(growable: true);
  List<Bullet> bullets = List.empty(growable: true);

  Server({@required this.game}) {
    world = World(game: game);
    planets.add(Planet(game: game));
    updateSpaceships();

    for (var i = 0; i < 250; i++) {
      debris.add(Debris(game: game));
    }
  }

  void updateSpaceships() {
    if (game.serverData != null) {
      game.serverData["players"].keys.forEach((player) {
        if (player != game.id) {
          dynamic spaceshipAngle =
              game.serverData["players"][player]["spaceship"]["angle"];

          List<dynamic> spaceshipPosition =
              game.serverData["players"][player]["spaceship"]["position"];

          // Create Spaceship
          if (!spaceships.containsKey(player)) {
            spaceships[player] = Spaceship(game: game);
          }

          // Update Position
          spaceships[player].setSpaceshipWorldPosition(
            Offset(
              spaceshipPosition[0].toDouble(),
              spaceshipPosition[1].toDouble(),
            ),
          );

          // Update Angle
          spaceships[player].lastMoveRadAngle = spaceshipAngle;
        }
      });
    }
  }

  void update(double t) {
    if (game.serverData != null) {
      // World
      world.update(t);

      // Spaceships
      if (spaceships != null) {
        spaceships.keys.forEach((s) => (spaceships[s].update(t)));
      }

      // Debris
      debris.forEach((d) => (d.update(t)));

      // Asteroids
      asteroids.forEach((a) => (a.update(t)));

      // Planets
      planets.forEach((p) => (p.update(t)));

      // Bullets
      bullets.forEach((b) => (b.update(t)));

      bullets.removeWhere((b) => b.life < 0);
    }
  }

  void render(Canvas canvas) {
    if (game.serverData != null) {
      // World
      world.render(canvas);

      // Spaceships
      if (spaceships != null) {
        spaceships.keys.forEach((s) {
          spaceships[s].render(canvas);
        });
      }

      // Debris
      debris.forEach((d) => (d.render(canvas)));

      // Asteroids
      asteroids.forEach((a) => (a.render(canvas)));

      // Planets
      planets.forEach((p) => (p.render(canvas)));

      // Bullets
      bullets.forEach((b) => b.render(canvas));
    }
  }
}
