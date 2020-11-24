import "package:flutter/material.dart";
import "package:web_socket_channel/io.dart";
import 'package:gameOff2020/mainGame.dart';

class GameLauncher extends StatelessWidget {
  MainGame game;

  GameLauncher() {
    game = MainGame();
  }

  @override
  Widget build(BuildContext context) {
    return game.widget;
  }
}
