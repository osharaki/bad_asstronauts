import "package:flame/util.dart";
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:gameOff2020/boxGame/boxGame.dart';
import 'package:gameOff2020/firebaseInit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();

  var boxGame = BoxGame();
  var tapper = TapGestureRecognizer();
  tapper.onTapDown = boxGame.onTapDown;

  runApp(FirebaseInit(boxGame));
}
