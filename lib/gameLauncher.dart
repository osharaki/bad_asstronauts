import 'package:flame_forge2d/flame_forge2d.dart';
import 'serverHandler.dart';

import 'mainMenu.dart';
import 'mainGame.dart';
import 'gameOverlay.dart';
import 'waitingRoom.dart';
import "package:flutter/material.dart";
import "package:web_socket_channel/io.dart";

class GameLauncher extends StatefulWidget {
  final Vector2 viewportSize;

  GameLauncher(this.viewportSize);

  @override
  GameLauncherState createState() => GameLauncherState();
}

class GameLauncherState extends State<GameLauncher> {
  // IP Addresses
  String androidIP = "ws://10.0.2.2:3000";
  String orlandoIP = "ws://192.168.1.183:3000";
  String winterGardenIP_2G = "ws://192.168.1.8:3000";
  String winterGardenIP_5G = "ws://192.168.1.4:3000";

  // UI Variables
  String state = "out";
  int remainingPlayers = 0;
  String remainingTime = "";
  Map<String, dynamic> playersInfo = {};

  MainGame game;
  IOWebSocketChannel channel;
  ServerHandler serverHandler;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(winterGardenIP_5G);
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

  void updateRemainingTime() {
    // setState(() {
    //   remainingTime =
    //       convertMillisecondsToTime(serverHandler.serverData["remainingTime"]);
    // });
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
