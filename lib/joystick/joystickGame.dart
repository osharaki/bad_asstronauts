import 'dart:convert';

import "package:flame/game.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:gameOff2020/joystick/trigger.dart';

import 'bullet.dart';
import 'server.dart';
import 'joystick.dart';
import "touchData.dart";

class JoystickGame extends Game {
  // Instance Variable
  Size screenSize;
  double tileSize;

  IOWebSocketChannel channel;

  String id;
  Server server;
  Map<String, dynamic> serverData = {};

  Trigger trigger;
  Joystick joystick;

  List<TouchData> taps = [];

  JoystickGame({@required this.channel}) {
    initialize();

    channel.stream.listen((rawMessage) => onReceiveMessage(rawMessage));
  }

  void initialize() async {
    // Wait for Flame to get final screen dimensions before passing it on to components
    resize(await Flame.util.initialDimensions());

    // Initialize Components
    server = Server(game: this);

    trigger = Trigger(game: this);
    joystick = Joystick(game: this);
  }

  @override
  void update(double t) {
    // Sync Components' update method with Game's
    if (serverData.isNotEmpty) {
      server.update(t);
      trigger.update(t);
      joystick.update(t);
    }
  }

  @override
  void render(Canvas canvas) {
    // Sync Components' render method with Game's
    if (serverData.isNotEmpty) {
      server.render(canvas);
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
        angle: server.spaceship.lastMoveRadAngle,
        startPosition: server.spaceship.rect.center,
      );

      server.bullets.add(bullet);

      // Empty
    } else {
      // Join
      if (serverData.isEmpty) {
        Map<String, dynamic> joinData = {
          "action": "join",
          "data": {"session": "test"},
        };

        channel.sink.add(json.encode(joinData));

        // Leave
      } else {
        Map<String, dynamic> leaveData = {
          "action": "leave",
          "data": {"session": "test"},
        };

        serverData.clear();
        channel.sink.add(json.encode(leaveData));
      }
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

  void sendMessageToServer({
    @required String action,
    @required Map<String, dynamic> data,
  }) {
    String message = jsonEncode({"action": action, "data": data});
    channel.sink.add(message);
  }

  void onReceiveMessage(String rawMessage) {
    Map message = jsonDecode(rawMessage);
    String action = message["action"];
    Map<String, dynamic> data = message["data"];

    // ACTIONS
    // Connect
    if (action == "connect") {
      // Store ID
      id = data["id"];
      print("MY ID: $id");
      print(data);

      // Join
    } else if (action == "join") {
      serverData = data;
      print("JOINED SESSION");
      print(data);

      // Update
    } else if (action == "update") {
      serverData = data;
      server.updateEnemies();
      print("UPDATED SESSION");
      print(data);
    }
  }
}
