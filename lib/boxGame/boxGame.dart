import 'dart:convert';
import 'dart:ffi';
import "dart:ui";
import 'package:flame/anchor.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:gameOff2020/boxGame/services/functions.dart';
import 'package:web_socket_channel/io.dart';

import 'box.dart';
import "package:flame/game.dart";
import "package:flame/flame.dart";
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";

class BoxGame extends Game with TapDetector {
  //Auth
  bool signedIn = false;

  // WebSocket channel
  IOWebSocketChannel webSocketChannel;

  // UI
  Box box;

  // Spacial
  Size screenSize;
  double tileSize;

  Map<String, dynamic> position;

  // QueryDocumentSnapshot activeSession;

  BoxGame({@required this.webSocketChannel}) {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    if (webSocketChannel != null) {
      if (webSocketChannel.sink != null) {
        webSocketChannel.stream.listen((message) {
          position = json.decode(message);
          if (box != null) box.updatePosition({'posX': position['posX'], 'posY': position['posY']});
        });
      }
    }

    box = Box(
      game: this,
    );
  }

  @override
  void render(Canvas canvas) {
    // Paint BG
    Rect bgRect = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height,
    );
    Paint bgPaint = Paint();
    bgPaint.color = Colors.black;

    canvas.drawRect(bgRect, bgPaint);

    if (box != null)
      box.render(canvas);
    else {
      TextConfig(fontSize: 20, color: Colors.white, textAlign: TextAlign.center).render(
          canvas,
          'loading box...',
          Position.fromOffset(Offset(screenSize.width / 2, screenSize.height / 2)),
          anchor: Anchor.center);
    }
  }

  @override
  void update(double t) {
    if (box != null) box.update(t);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.height / 9;
  }

  void onTapDown(TapDownDetails details) async {
    if (box != null) {
      if (box.rect.contains(details.globalPosition)) {
        triggerBoxPosUpdate();
      }
    }
  }

  triggerBoxPosUpdate() {
    webSocketChannel.sink.add(json.encode({'action': 'New pos'}));
  }
}
