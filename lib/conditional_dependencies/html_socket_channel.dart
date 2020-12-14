import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_channel_interface.dart';
import "package:web_socket_channel/html.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HtmlSocketChannel implements SocketChannel {
  HtmlWebSocketChannel channel = HtmlWebSocketChannel.connect(DotEnv().env['WSS_LOCALHOST']);

  @override
  WebSocketSink get sink => channel.sink;

  @override
  Stream get stream => channel.stream;
}

SocketChannel getSocketChannel() => HtmlSocketChannel();
