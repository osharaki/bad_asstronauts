import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:gameOff2020/player.dart';
import 'package:gameOff2020/spaceship.dart';

class MainGame extends BaseGame with MultiTouchDragDetector {
  Spaceship spaceship;
  Player player;

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
    player = Player(this);
    joystick.addObserver(player);
    add(player);
    add(joystick);
    add(MyCircle(
        this)); // at this point, size is still Vector2.zero(). See https://pub.dev/documentation/flame/1.0.0-rc2/game_base_game/BaseGame/size.html
  }

  /* void initialize() {
    joystick.addObserver(spaceship);
    // add(spaceship);
    add(joystick);
  } */

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = Colors.white);
  }

  /* @override
  Future<void> onLoad() async {
    print('called onload');
    Image spaceshipImage = await images.load('spaceship.png');
    spaceship = Spaceship(Sprite(spaceshipImage), Vector2(25.4, 51.2));
    initialize();
  } */
}

class MyCircle extends PositionComponent {
  final MainGame game;
  MyCircle(this.game);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(game.size.x / 2, game.size.y / 2), 10, Paint()..color = Colors.white);
  }
}
