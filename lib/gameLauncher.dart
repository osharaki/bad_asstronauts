import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:flutter/material.dart";
import 'package:flutter/foundation.dart' show kIsWeb;

import 'conditional_dependencies/socket_channel_interface.dart';
import 'serverHandler.dart';
import 'mainMenu.dart';
import 'mainGame.dart';
import 'gameOverlay.dart';
import 'waitingRoom.dart';

class GameLauncher extends StatefulWidget {
  final Vector2 viewportSize;

  GameLauncher(this.viewportSize);

  @override
  GameLauncherState createState() => GameLauncherState();
}

class GameLauncherState extends State<GameLauncher> {
  // UI Variables
  String state = "out";
  int remainingPlayers = 0;
  int respawnTime = 5;
  Map<String, dynamic> playersInfo = {};

  MainGame game;
  SocketChannel channel = SocketChannel();
  ServerHandler serverHandler;

  @override
  void initState() {
    super.initState();
    serverHandler = ServerHandler(launcher: this);
    game = MainGame(launcher: this, viewportSize: widget.viewportSize);
  }

  void updateState(String newState) {
    setState(() {
      state = newState;
    });
  }

  void updateRemainingPlayers(int players) {
    setState(() {
      remainingPlayers = players;
    });
  }

  void updatePlayersInfo(Map<String, dynamic> newPlayersInfo) {
    // print(newPlayersInfo);
    updateRemainingPlayers(newPlayersInfo.length);

    setState(() {
      playersInfo = newPlayersInfo;
    });
  }

  String convertMillisecondsToTime(int milliseconds) {
    double seconds = milliseconds / 1000;
    double timeDecimal = seconds / 60;
    int minute = timeDecimal.floor();
    double secondDecimal = timeDecimal - minute;
    double second = secondDecimal * 60;
    String time = "$minute:${second.round().toString().padLeft(2, '0')}";

    return time;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          game.widget,
          state == "out" ? MainMenu(launcher: this) : Container(),
          state == "waiting" ? WaitingRoom(launcher: this) : Container(),
          state == "playing" ? GameOverlay(launcher: this) : Container(),
        ],
      ),
    );
  }
}
