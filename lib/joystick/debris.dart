import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/joystickGame.dart';
import 'package:gameOff2020/utils/math.dart';

class Debris {
  JoystickGame game;
  Rect rect;
  double size;
  Offset position;
  Paint paint = Paint();
  double sizeMultiplier;
  double minSizeMultiplier = 0.1;
  double maxSizeMultiplier = 0.5;

  Debris({@required this.game}) {
    sizeMultiplier = getRandomValueInRange(
      min: minSizeMultiplier,
      max: maxSizeMultiplier,
    );

    size = game.tileSize * sizeMultiplier;

    position = Offset(
      getRandomValueInRange(min: 1, max: 2500.0),
      getRandomValueInRange(min: 1, max: 2500.0),
    );

    rect = Rect.fromCircle(
      center: position,
      radius: size,
    );

    paint.color = Colors.brown[800];
  }

  void update(double t) {
    // Debris' offset from it's next position
    var difference = Offset(
          rect.center.dx - game.joystick.nextOffset.dx,
          rect.center.dy - game.joystick.nextOffset.dy,
        ) -
        rect.center;

    // Shift Debris to it's next position
    rect = rect.shift(difference);
  }

  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}
