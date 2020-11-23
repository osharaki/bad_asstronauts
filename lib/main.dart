import "package:flame/util.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:gameOff2020/gameLauncher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WebSocket Channel
  // IOWebSocketChannel channel = IOWebSocketChannel.connect("ws://10.0.2.2:3000");

  // Using Laptop's Local IP Address
  IOWebSocketChannel channel =
      IOWebSocketChannel.connect("ws://192.168.1.106:3000");

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  await SystemChrome.setEnabledSystemUIOverlays([]);

  Flame.images.loadAll([
    "spaceship.png",
    "joystickKnob.png",
    "joystickBase.png",
  ]);

  runApp(GameLauncher(channel: channel));
}
