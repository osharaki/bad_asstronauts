import 'dart:ui';

import "package:flutter/material.dart" hide Image;
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
