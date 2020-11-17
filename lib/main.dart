import "package:flame/util.dart";
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();

  // WebSocket stuff
  IOWebSocketChannel channel = new IOWebSocketChannel.connect("ws://192.168.1.106:3000");

  if (channel != null) {
    if (channel.sink != null) {
      channel.sink.add('hi server!');
      channel.stream.listen((message) {
        channel.sink.add('received message!');
        print('Msg from server: $message');
      });
    }
  }
  // runApp(FirebaseInit());
  // runApp(boxGame.widget);
}
