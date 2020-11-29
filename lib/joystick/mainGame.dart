import "package:flame/game.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:gameOff2020/utils/math.dart';

import 'bullet.dart';
import 'joystick.dart';
import 'gameLauncher.dart';

class MainGame extends Game {
  // Instance Variable
  Size screenSize;
  double tileSize;
  Offset screenCenter;

  final GameLauncherState launcher;

  Trigger trigger;
  Joystick joystick;

  List<TouchData> taps = [];

  MainGame({@required this.launcher}) {
    initialize();
  }

  void initialize() async {
    // Wait for Flame to get final screen dimensions before passing it on to components
    resize(await Flame.util.initialDimensions());

    // Initialize Components
    trigger = Trigger(game: this);
    joystick = Joystick(game: this);
  }

  @override
  void update(double t) {
    // Sync Components' update method with Game's
    if (launcher.serverHandler.serverData["state"] == "playing") {
      launcher.serverHandler.update(t);
      trigger.update(t);
      joystick.update(t);
    }
  }

  @override
  void render(Canvas canvas) {
    // Sync Components' render method with Game's
    if (launcher.serverHandler.serverData["state"] == "playing") {
      launcher.serverHandler.render(canvas);
      trigger.render(canvas);
      joystick.render(canvas);
    }
  }

  @override
  void resize(Size size) {
    // Update Screen size based on device and orientation
    screenSize = size;

    // Get Tile Size to maintain uniform component size on all devices
    tileSize = screenSize.height / 9; // 16:9

    screenCenter = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );
  }

  // Sync Gestures with Components' Gesture methods
  void onTap(TouchData touch) {
    taps.add(touch);

    // Joystick
    if (joystick.baseRect.contains(touch.offset)) {
      joystick.onTap(touch);

      // Trigger
    } else if (trigger.rect.contains(touch.offset)) {
      Bullet bullet = Bullet(
        game: this,
        angle: launcher.serverHandler.players[launcher.serverHandler.id]["spaceship"].angle,
        startPosition:
            launcher.serverHandler.players[launcher.serverHandler.id]["spaceship"].worldPosition +
                Offset(
                  launcher.serverHandler.players[launcher.serverHandler.id]["spaceship"].size / 2,
                  launcher.serverHandler.players[launcher.serverHandler.id]["spaceship"].size / 4,
                ),
      );

      launcher.serverHandler.bullets.add(bullet);
    }
  }

  void onDrag(TouchData touch) {
    for (int i = 0; i < taps.length; i++) {
      if (taps[i].touchId == touch.touchId) {
        taps[i] = touch;

        break;
      }
    }

    if (touch.touchId == joystick.touchId) joystick.onDrag(touch);
  }

  void onRelease(TouchData touch) {
    taps.removeWhere((tap) => tap.touchId == touch.touchId);

    if (touch.touchId == joystick.touchId) joystick.onRelease();
  }

  void onCancel(TouchData touch) {
    taps.removeWhere((tap) => tap.touchId == touch.touchId);
  }
}
