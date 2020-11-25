import 'dart:ui';

import "package:flame/util.dart";
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:gameOff2020/gameLauncher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WebSocket Channel
  // IOWebSocketChannel channel = IOWebSocketChannel.connect("ws://10.0.2.2:3000");

  // Using Laptop's Local IP Address
  IOWebSocketChannel channel = IOWebSocketChannel.connect("ws://192.168.1.106:3000");

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  // Vector2 viewportSize = await flameUtil.initialDimensions();
  await SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(GameLauncher());
}
