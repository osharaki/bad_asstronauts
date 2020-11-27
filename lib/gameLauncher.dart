import 'dart:ui';

import "package:flutter/material.dart" hide Image;
import 'package:gameOff2020/mainGame.dart';

class GameLauncher extends StatelessWidget {
  MainGame game;

  GameLauncher(viewportSize) {
    game = MainGame(viewportSize);
  }

  @override
  Widget build(BuildContext context) {
    return game.widget;
  }
}
