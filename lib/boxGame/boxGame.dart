import "dart:ui";
import 'package:flame/anchor.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:gameOff2020/boxGame/services/functions.dart';

import 'box.dart';
import "package:flame/game.dart";
import "package:flame/flame.dart";
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class BoxGame extends Game with TapDetector {
  //Auth
  bool signedIn = false;

  // UI
  Box box;

  // Spacial
  Size screenSize;
  double tileSize;

  // QueryDocumentSnapshot activeSession;

  BoxGame() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());

    DocumentSnapshot position =
        await FirebaseFirestore.instance.collection('game').doc('position').get();
    if (!position.exists)
      // prompt server to calculate the initial box position if no position document exists
      triggerBoxPosUpdate();
    position.reference.snapshots().listen((event) {
      if (box != null)
        box.updatePosition({'posX': event.data()['posX'], 'posY': event.data()['posY']});
    });
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
}
