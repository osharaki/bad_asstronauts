import "package:flutter/material.dart";
import "package:web_socket_channel/io.dart";
import 'package:gameOff2020/mainGame.dart';

class GameLauncher extends StatelessWidget {
  // WebSocket Channel
  IOWebSocketChannel channel;

  MainGame game;
  int touchCounter = 0;

  GameLauncher({@required this.channel}) {
    game = MainGame();
  }

  @override
  Widget build(BuildContext context) {
    return game.widget;
  }
}
