import 'package:flutter/material.dart';

import 'arena.dart';
import 'bullet.dart';
import 'debris.dart';
import 'planet.dart';
import 'asteroid.dart';
import 'mainGame.dart';
import 'spaceship.dart';

class ServerHandler {
  MainGame game;

  Arena arena;

  Map<String, Spaceship> spaceships = {};

  List<Debris> debris = List.empty(growable: true);
  List<Planet> planets = List.empty(growable: true);
  List<Bullet> bullets = List.empty(growable: true);
  List<Asteroid> asteroids = List.empty(growable: true);

  ServerHandler({@required this.game}) {
    arena = Arena(game: game);
    planets.add(Planet(game: game));

    for (var i = 0; i < 250; i++) {
      debris.add(Debris(game: game));
    }
  }

  void updateSpaceships() {
    // Remove disconnected spaceships
    spaceships.removeWhere((spaceship, value) =>
        !game.serverData["players"].keys.contains(spaceship));

    // For each player in serverHandler data
    game.serverData["players"].keys.forEach((player) {
      // Create Spaceship
      if (player == game.id) {
        if (!spaceships.containsKey(player)) {
          spaceships[player] = Spaceship(game: game);
        }
      } else {
        if (!spaceships.containsKey(player)) {
          spaceships[player] = Spaceship(game: game, centered: false);
        }

        // Get other spaceships' info
        dynamic angle =
            game.serverData["players"][player]["spaceship"]["angle"];

        Offset position = game.getWorldPositionFromPercent(
            game.serverData["players"][player]["spaceship"]["position"]);

        // Update info
        spaceships[player].worldPosition = position;
        spaceships[player].lastMoveRadAngle = angle.toDouble();
      }
    });
  }

  void update(double t) {
    // Arena
    arena.update(t);

    // Spaceships
    spaceships.keys.forEach((s) {
      spaceships[s].update(t);
    });

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

  void render(Canvas canvas) {
    // Arena
    arena.render(canvas);

    // Spaceships
    spaceships.keys.forEach((s) {
      spaceships[s].render(canvas);
    });

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
