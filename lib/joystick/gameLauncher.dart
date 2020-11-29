import 'package:gameOff2020/joystick/gameOverlay.dart';
import 'package:gameOff2020/joystick/serverHandler.dart';

import 'mainMenu.dart';
import 'itemDrag.dart';
import 'mainGame.dart';
import 'touchData.dart';
import 'waitingRoom.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import "package:web_socket_channel/io.dart";

class GameLauncher extends StatefulWidget {
  @override
  GameLauncherState createState() => GameLauncherState();
}

class GameLauncherState extends State<GameLauncher> {
  // IP Addresses
  String androidIP = "ws://10.0.2.2:3000";
  String orlandoIP = "ws://192.168.1.183:3000";
  String winterGardenIP_2G = "ws://192.168.1.8:3000";
  String winterGardenIP_5G = "ws://192.168.1.4:3000";

  String state = "out";
  int remainingPlayers = 0;
  String remainingTime = "";
  Map<String, dynamic> playersInfo = {};

  MainGame game;
  IOWebSocketChannel channel;
  ServerHandler serverHandler;

  int touchCounter = 0;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(winterGardenIP_5G);
    serverHandler = ServerHandler(launcher: this);
    game = MainGame(launcher: this);
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
    setState(() {
      remainingTime =
          convertMillisecondsToTime(serverHandler.serverData["remainingTime"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          RawGestureDetector(
            child: game.widget,
            gestures: <Type, GestureRecognizerFactory>{
              ImmediateMultiDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      ImmediateMultiDragGestureRecognizer>(
                () => ImmediateMultiDragGestureRecognizer(),
                (ImmediateMultiDragGestureRecognizer instance) {
                  instance.onStart = (Offset offset) {
                    touchCounter++;
                    game.onTap(TouchData(touchCounter, offset));
                    return ItemDrag((details, tId) {
                      game.onDrag(TouchData(tId, details.globalPosition));
                    }, (details, tId) {
                      game.onRelease(TouchData(tId, Offset(0, 0)));
                    }, (tId) {
                      game.onCancel(TouchData(tId, Offset(0, 0)));
                    }, touchCounter);
                  };
                },
              )
            },
          ),
          state == "waiting"
              ? WaitingRoom(launcher: this)
              : Container(width: 0, height: 0),
          state == "out"
              ? MainMenu(launcher: this)
              : Container(width: 0, height: 0),
          state == "playing"
              ? GameOverlay(launcher: this)
              : Container(width: 0, height: 0),
        ],
      ),
    );
  }
}
