import 'package:flutter/material.dart';

import 'bullet.dart';

import 'world.dart';
import "enemy.dart";
import 'debris.dart';
import 'planet.dart';
import 'asteroid.dart';

import 'joystickGame.dart';

class Server {
  JoystickGame game;
  World world;
  List<dynamic> spaceships = List.empty(growable: true);
  List<Debris> debris = List.empty(growable: true);
  List<Planet> planets = List.empty(growable: true);
  List<Asteroid> asteroids = List.empty(growable: true);
  List<Bullet> bullets = List.empty(growable: true);

  Server({@required this.game}) {
    world = World(game: game);
    planets.add(Planet(game: game));
    spaceships.add(Enemy(game: game));

    for (var i = 0; i < 250; i++) {
      debris.add(Debris(game: game));
    }
  }

  void update(double t) {
    // World
    world.update(t);

    // Spaceships
    spaceships.forEach((s) => (s.update(t)));

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

    // Spaceships
    spaceships.forEach((s) => (s.render(canvas)));

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
