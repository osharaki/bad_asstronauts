import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import "package:web_socket_channel/io.dart";
import 'package:gameOff2020/joystick/itemDrag.dart';
import 'package:gameOff2020/joystick/touchData.dart';
import 'package:gameOff2020/joystick/mainGame.dart';

class GameLauncher extends StatelessWidget {
  // WebSocket Channel
  IOWebSocketChannel channel;

  MainGame game;
  int touchCounter = 0;

  GameLauncher({@required this.channel}) {
    game = MainGame(channel: channel);
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      child: game.widget,
      gestures: <Type, GestureRecognizerFactory>{
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                ImmediateMultiDragGestureRecognizer>(
          () => ImmediateMultiDragGestureRecognizer(),
          (ImmediateMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset offset) {
              touchCounter++;
              game.onTap(TouchData(touchCounter, offset));
              return ItemDrag((details, tId) {
                game.onDrag(TouchData(tId, details.globalPosition));
              }, (details, tId) {
                game.onRelease(TouchData(tId, Offset(0, 0)));
              }, (tId) {
                game.onCancel(TouchData(tId, Offset(0, 0)));
              }, touchCounter);
            };
          },
        )
      },
    );
  }
}
