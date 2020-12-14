import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_channel_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'io_socket_channel.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'html_socket_channel.dart';

abstract class SocketChannel {
  final Stream stream;
  final WebSocketSink sink;

  // factory constructor to return the correct implementation.
  factory SocketChannel() => getSocketChannel();
}
