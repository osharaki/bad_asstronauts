import "package:flame/util.dart";
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';

import 'boxGame/boxGame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();

  // WebSocket stuff
  IOWebSocketChannel channel =
      new IOWebSocketChannel.connect("ws://10.0.2.2:3000");

  // runApp(FirebaseInit());
  var boxGame = BoxGame(webSocketChannel: channel);
  var tapper = TapGestureRecognizer();

  tapper.onTapDown = boxGame.onTapDown;
  runApp(boxGame.widget);
}
