import "package:flame/util.dart";
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  IOWebSocketChannel channel = new IOWebSocketChannel.connect("ws://10.0.2.2:3000");

  // runApp(FirebaseInit());
  // runApp(boxGame.widget);
}
