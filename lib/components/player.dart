import 'dart:math';
import 'dart:ui';

import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:gameOff2020/mainGame.dart';

class Player extends BodyComponent implements JoystickListener {
  final _whitePaint = BasicPalette.white.paint;
  final _bluePaint = Paint()..color = const Color(0xFF0000FF);
  final _greenPaint = Paint()..color = const Color(0xFF00FF00);
  final double speed = 159;
  double currentSpeed = 0;
  double radAngle = 0;
  bool _move = false;
  Paint _paint;

  Rect _rect;

  final MainGame game;

  Player(this.game) {
    _paint = _whitePaint;
  }

  // @override
  // void render(Canvas canvas) {
  //   if (_rect != null) {
  //     canvas.save();
  //     canvas.translate(_rect.center.dx, _rect.center.dy);
  //     canvas.rotate(radAngle == 0.0 ? 0.0 : radAngle + (pi / 2));
  //     canvas.translate(-_rect.center.dx, -_rect.center.dy);
  //     canvas.drawRect(_rect, _paint);
  //     canvas.restore();
  //   }
  // }

  @override
  void update(double dt) {
    super.update(dt);
    if (_move) {
      moveFromAngle(dt);
    }

    /* // this centers camera on this component
    // https://fireslime.xyz/articles/20190911_Basic_Camera_Usage_In_Flame.html
    game.camera.x = body.position.x;
    game.camera.y = -body.position.y; */
  }

  @override
  void onGameResize(Vector2 size) {
    _rect = Rect.fromLTWH(
      (size.x / 2) - 25,
      (size.y / 2) - 25,
      50,
      50,
    );
    super.onGameResize(size);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == 1) {
        _paint = _paint == _whitePaint ? _bluePaint : _whitePaint;
      }
      if (event.id == 2) {
        _paint = _paint == _whitePaint ? _greenPaint : _whitePaint;
      }
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _move = event.directional != JoystickMoveDirectional.IDLE;
    if (_move) {
      radAngle = event.radAngle;
      currentSpeed = speed * event.intensity;
    }
  }

  void moveFromAngle(double dtUpdate) {
    final double nextX = (currentSpeed * dtUpdate) * cos(radAngle);
    final double nextY = (currentSpeed * dtUpdate) * sin(radAngle);

    final Offset diffBase = Offset(
          _rect.center.dx + nextX,
          _rect.center.dy + nextY,
        ) -
        _rect.center;

    _rect = _rect.shift(diffBase);

    body.applyLinearImpulse(Vector2(nextX, -nextY).scaled(20), body.worldCenter, true);
  }

  @override
  Body createBody() {
    final PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(25, 25);

    final fixtureDef = FixtureDef()..shape = shape;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..setUserData(this)
      ..position = game.size.scaled(0.5)
      ..type = BodyType.DYNAMIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
