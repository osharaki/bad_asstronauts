import 'dart:ui';

import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/sprite.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame/gestures.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Image;

class MainGame extends Forge2DGame with MultiTouchDragDetector {
  final joystick = JoystickComponent(
      directional: JoystickDirectional(
    isFixed: true, // optional
    size: 80, // optional
    color: Colors.blueGrey, // optional
    opacityBackground: 0.5, // optional
    opacityKnob: 0.8, // optional
  ));

  // Instance Variable
  Size screenSize;
  double tileSize;

  MainGame()
      : super(
          scale: 4.0,
          gravity: Vector2(0, 0),
        ) {
    initialize();
  }

  void initialize() async {
    viewport.resize(Vector2(screenSize.width, screenSize.height));
  }
}
