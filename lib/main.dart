import "package:flame/util.dart";
import 'package:flutter/material.dart';
import 'package:gameOff2020/firebaseInit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();

  runApp(FirebaseInit());
  // runApp(boxGame.widget);
}
