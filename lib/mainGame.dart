import 'dart:ui';

import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:gameOff2020/player.dart';

class MainGame extends BaseGame with MultiTouchDragDetector {
  final player = Player();

  final joystick = JoystickComponent(
    directional: JoystickDirectional(),
    actions: [
      JoystickAction(
        actionId: 1,
        size: 50,
        margin: const EdgeInsets.all(50),
        color: const Color(0xFF0000FF),
      ),
      JoystickAction(
        actionId: 2,
        size: 50,
        color: const Color(0xFF00FF00),
        margin: const EdgeInsets.only(
          right: 50,
          bottom: 120,
        ),
      ),
      JoystickAction(
        actionId: 3,
        size: 50,
        margin: const EdgeInsets.only(bottom: 50, right: 120),
        enableDirection: true,
      ),
    ],
  );

  MainGame() {
    joystick.addObserver(player);
    add(player);
    add(joystick);
  }

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = Colors.white);
  }
}
