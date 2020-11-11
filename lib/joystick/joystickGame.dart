import 'package:flame/flame.dart';
import "package:flame/game.dart";
import 'package:flutter/material.dart';

import 'world.dart';
import 'enemy.dart';
import 'debris.dart';
import 'planet.dart';
import 'server.dart';
import 'joystick.dart';
import 'spaceship.dart';

class JoystickGame extends Game {
  // Instance Variable
  Size screenSize;
  double tileSize;

  Server server;
  Joystick joystick;
  Spaceship spaceship;

  JoystickGame() {
    initialize();
  }

  void initialize() async {
    // Wait for Flame to get final screen dimensions before passing it on to components
    resize(await Flame.util.initialDimensions());

    // Initialize Components
    server = Server();

    server.world = World(game: this);
    server.planets.add(Planet(game: this));
    server.spaceships.add(Enemy(game: this));

    for (var i = 0; i < 250; i++) {
      server.debris.add(Debris(game: this));
    }

    spaceship = Spaceship(game: this);
    joystick = Joystick(game: this);
  }

  @override
  void update(double t) {
    // Sync Components' update method with Game's
    server.update(t);
    spaceship.update(t);
    joystick.update(t);
  }

  @override
  void render(Canvas canvas) {
    // Sync Components' render method with Game's
    server.render(canvas);
    spaceship.render(canvas);
    joystick.render(canvas);
  }

  @override
  void resize(Size size) {
    // Update Screen size based on device and orientation
    screenSize = size;

    // Get Tile Size to maintain uniform component size on all devices
    tileSize = screenSize.height / 9; // 16:9
  }

  // Sync Gestures with Components' Gesture methods
  void onPanStart(DragStartDetails details) {
    joystick.onPanStart(details);
  }

  void onPanUpdate(DragUpdateDetails details) {
    joystick.onPanUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    joystick.onPanEnd(details);
  }
}
