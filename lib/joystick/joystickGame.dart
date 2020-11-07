import 'package:flame/flame.dart';
import "package:flame/game.dart";
import 'package:flutter/material.dart';
import 'package:gameOff2020/joystick/spaceship.dart';

import 'joystick.dart';

class JoystickGame extends Game {
  // Instance Variable
  Size screenSize;
  double tileSize;
  Joystick joystick;
  Spaceship spaceship;

  JoystickGame() {
    initialize();
  }

  void initialize() async {
    // Wait for Flame to get final screen dimensions before passing it on to components
    resize(await Flame.util.initialDimensions());

    // Initialize Components
    spaceship = Spaceship(game: this);
    joystick = Joystick(game: this);
  }

  @override
  void update(double t) {
    // Sync Components' update method with Game's
    spaceship.update(t);
    joystick.update(t);
  }

  @override
  void render(Canvas canvas) {
    // Sync Components' render method with Game's
    spaceship.render(canvas);
    joystick.render(canvas);
  }

  @override
  void resize(Size size) {
    // Update Screen size based on device and orientation
    screenSize = size;

    // Get Tile Size to maintain uniform component size on all devices
    tileSize = size.height / 9;
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
