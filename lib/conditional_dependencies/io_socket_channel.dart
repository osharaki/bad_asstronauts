import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_channel_interface.dart';
import "package:web_socket_channel/io.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IOSocketChannel implements SocketChannel {
  IOWebSocketChannel channel = IOWebSocketChannel.connect(DotEnv().env['WSS_IP']);

  @override
  WebSocketSink get sink => channel.sink;

  @override
  Stream get stream => channel.stream;
}

SocketChannel getSocketChannel() => IOSocketChannel();
