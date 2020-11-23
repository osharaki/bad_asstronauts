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

  // {"id": {"spaceship":Spaceship(), "planet":Planet()}}
  Map<String, Map<String, dynamic>> players = {};

  List<Debris> debris = List.empty(growable: true);
  List<Bullet> bullets = List.empty(growable: true);
  List<Asteroid> asteroids = List.empty(growable: true);

  ServerHandler({@required this.game}) {
    arena = Arena(game: game);

    for (var i = 0; i < 250; i++) {
      debris.add(Debris(game: game));
    }
  }

  void joinSession() {
    game.serverData["players"].keys.forEach((player) {
      addPlayer(player);
    });
  }

  void addPlayer(String player) {
    // Add player
    bool centered = player == game.id ? true : false;

    players[player] = {
      "spaceship": Spaceship(game: game, centered: centered),
      "planet": Planet(game: game),
    };
  }

  void removePlayer(String player) {
    // Remove player
    players.remove(player);
  }

  void updatePlayers() {
    players.keys.forEach((player) {
      dynamic angle = game.serverData["players"][player]["spaceship"]["angle"];

      Offset position = game.getWorldPositionFromPercent(
          game.serverData["players"][player]["spaceship"]["position"]);

      Offset planetPosition = game.getWorldPositionFromPercent(
          game.serverData["players"][player]["planet"]["position"]);

      // Update info
      players[player]["spaceship"].worldPosition = position;
      players[player]["spaceship"].angle = angle.toDouble();

      players[player]["planet"].position = planetPosition;
    });
  }

  void update(double t) {
    // Arena
    arena.update(t);

    // Debris
    debris.forEach((d) => (d.update(t)));

    // Asteroids
    asteroids.forEach((a) => (a.update(t)));

    // Bullets
    bullets.forEach((b) => (b.update(t)));

    bullets.removeWhere((b) => b.life < 0);

    // Planets
    players.keys.forEach((player) {
      players[player]["planet"].update(t);
    });

    // Spaceships
    players.keys.forEach((player) {
      players[player]["spaceship"].update(t);
    });
  }

  void render(Canvas canvas) {
    // Arena
    arena.render(canvas);

    // Debris
    debris.forEach((d) => (d.render(canvas)));

    // Asteroids
    asteroids.forEach((a) => (a.render(canvas)));

    // Bullets
    bullets.forEach((b) => b.render(canvas));

    // Planets
    players.keys.forEach((player) {
      players[player]["planet"].render(canvas);
    });

    // Spaceships
    players.keys.forEach((player) {
      players[player]["spaceship"].render(canvas);
    });
  }
}
