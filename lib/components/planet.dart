import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planetSensor.dart';

import '../mainGame.dart';

class Planet extends SpriteBodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final PlanetSensor planetSensor;

  Planet(this.game, Image image, {this.size, this.position})
      : planetSensor = PlanetSensor(game, size: size, position: position),
        super(Sprite(image), size) {
    game.add(planetSensor);
  }

  @override
  Body createBody() {
    final CircleShape shape = CircleShape()..radius = size.x / 2;

    final fixtureDef = FixtureDef();
    fixtureDef.setUserData(this); // To be able to determine object in collision
    fixtureDef.shape = shape;

    paint.color = Colors.transparent;

    final bodyDef = BodyDef();
    bodyDef.position = position;
    bodyDef.type = BodyType.STATIC;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
