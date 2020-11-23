import 'dart:convert';
import "package:flame/game.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:gameOff2020/utils/math.dart';

import 'bullet.dart';
import 'trigger.dart';
import 'joystick.dart';
import 'touchData.dart';
import 'serverHandler.dart';

class MainGame extends Game {
  // Instance Variable
  Size screenSize;
  double tileSize;
  Offset screenCenter;

  IOWebSocketChannel channel;

  String id;
  ServerHandler serverHandler;
  Map<String, dynamic> serverData = {};

  Trigger trigger;
  Joystick joystick;

  List<TouchData> taps = [];

  MainGame({@required this.channel}) {
    initialize();

    channel.stream.listen((rawMessage) => onReceiveMessage(rawMessage));
  }

  void initialize() async {
    // Wait for Flame to get final screen dimensions before passing it on to components
    resize(await Flame.util.initialDimensions());

    // Initialize Components
    serverHandler = ServerHandler(game: this);

    trigger = Trigger(game: this);
    joystick = Joystick(game: this);
  }

  @override
  void update(double t) {
    // Sync Components' update method with Game's
    if (serverData.isNotEmpty) {
      serverHandler.update(t);
      trigger.update(t);
      joystick.update(t);
    }
  }

  @override
  void render(Canvas canvas) {
    // Sync Components' render method with Game's
    if (serverData.isNotEmpty) {
      serverHandler.render(canvas);
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
        angle: serverHandler.players[id]["spaceship"].angle,
        startPosition: serverHandler.players[id]["spaceship"].worldPosition +
            Offset(
              serverHandler.players[id]["spaceship"].size / 2,
              serverHandler.players[id]["spaceship"].size / 4,
            ),
      );

      serverHandler.bullets.add(bullet);

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

  Offset getWorldPositionFromPercent(List<dynamic> percent) {
    var x = mapValue(
      aValue: serverHandler.arena.size.width,
      bValue: 100,
      bMatch: percent[0],
    );

    var y = mapValue(
      aValue: serverHandler.arena.size.height,
      bValue: 100,
      bMatch: percent[1],
    );

    var worldPosition = Offset(x, y);

    return worldPosition;
  }

  List<dynamic> getPercentFromWorldPosition(Offset position) {
    var x = mapValue(
      aValue: 100,
      bValue: serverHandler.arena.size.width,
      bMatch: position.dx,
    );

    var y = mapValue(
      aValue: 100,
      bValue: serverHandler.arena.size.height,
      bMatch: position.dy,
    );

    List<dynamic> percent = [x, y];

    return percent;
  }

  void sendDataToServer({
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

      // Update
    } else if (action == "update") {
      serverData = data;
      serverHandler.updatePlayers();

      // Player Joined
    } else if (action == "playerJoined") {
      serverData = data["info"];
      String player = data["player"];

      if (player == id) {
        serverHandler = ServerHandler(game: this);
        serverHandler.joinSession();
        moveCameraToPercent(
            data["info"]["players"][id]["spaceship"]["position"]);
      } else {
        serverHandler.addPlayer(player);
      }

      // Player Left
    } else if (action == "playerLeft") {
      serverHandler.removePlayer(data["player"]);
    }
  }

  void moveCameraToPercent(List<dynamic> percent) {
    // Position at screen top left corner
    Offset position = getWorldPositionFromPercent(percent);

    // Move position to screen center
    position = screenCenter - position;

    // Check if screen exceeds arena boundaries
    // Left
    if (position.dx > 0) position = Offset(0, position.dy);

    // Right
    if (position.dx.abs() + screenCenter.dx > serverHandler.arena.size.width)
      position = Offset(
          (serverHandler.arena.size.width * -1) + screenSize.width,
          position.dy);

    // Top
    if (position.dy > 0) position = Offset(position.dx, 0);

    // Bottom
    if (position.dy.abs() + screenCenter.dy > serverHandler.arena.size.height)
      position = Offset(position.dx,
          (serverHandler.arena.size.height * -1) + screenSize.height);

    // Assign final position to arena
    serverHandler.arena.position = position;
  }
}
