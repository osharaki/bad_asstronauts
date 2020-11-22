import 'package:flutter/material.dart';

import 'enemy.dart';
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
  Spaceship spaceship;
  Map<String, Enemy> enemies = {};
  List<Debris> debris = List.empty(growable: true);
  List<Planet> planets = List.empty(growable: true);
  List<Asteroid> asteroids = List.empty(growable: true);
  List<Bullet> bullets = List.empty(growable: true);

  Server({@required this.game}) {
    world = World(game: game);
    planets.add(Planet(game: game));
    spaceship = Spaceship(game: game);

    for (var i = 0; i < 250; i++) {
      debris.add(Debris(game: game));
    }
  }

  void updateEnemies() {
    // Remove disconnected enemies
    enemies.removeWhere(
        (enemy, value) => !game.serverData["players"].keys.contains(enemy));

    // For each player in server data
    game.serverData["players"].keys.forEach((player) {
      // Other players are Enemies
      if (player != game.id) {
        dynamic angle =
            game.serverData["players"][player]["spaceship"]["angle"];

        List<dynamic> position =
            game.serverData["players"][player]["spaceship"]["position"];

        // Create Enemy
        if (!enemies.containsKey(player)) {
          enemies[player] = Enemy(game: game);
        }

        // Update Position
        enemies[player].position = position;

        // Update Angle
        enemies[player].angle = angle.toDouble();
      }
    });
  }

  void update(double t) {
    // World
    world.update(t);

    // Spaceship
    spaceship.update(t);

    // Enemies
    enemies.keys.forEach((s) {
      enemies[s].update(t);
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
    // World
    world.render(canvas);

    // Spaceship
    spaceship.render(canvas);

    // Enemies
    enemies.keys.forEach((s) {
      enemies[s].render(canvas);
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
