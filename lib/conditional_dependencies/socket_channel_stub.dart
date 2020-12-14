import 'socket_channel_interface.dart';

SocketChannel getSocketChannel() => throw UnsupportedError(
    'Cannot create a socket channel without the packages web_socket_channel/io.dart or web_socket_channel/html.dart');
