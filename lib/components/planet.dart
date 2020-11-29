import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planetAtmosphere.dart';

import '../mainGame.dart';
import 'spaceship.dart';

class Planet extends SpriteBodyComponent {
  final MainGame game;
  final Vector2 size;
  final Vector2 position;
  final spaceshipId;
  final TextConfig resourceDisplayConfig = TextConfig(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
    textAlign: TextAlign.center,
  );

  PlanetAtmosphere planetAtmosphere;
  double resources;

  Planet({
    @required this.game,
    @required Image image,
    @required this.spaceshipId,
    @required this.resources,
    this.size,
    this.position,
  }) : super(Sprite(image), size) {
    planetAtmosphere = PlanetAtmosphere(
      game: game,
      planet: this,
      size: size,
      position: position,
    );
    game.add(planetAtmosphere);
  }

  @override
  Body createBody() {
    final CircleShape shape = CircleShape()..radius = size.x / 2;

    final fixtureDef = FixtureDef();
    fixtureDef.shape = shape;

    paint.color = Colors.transparent;

    final bodyDef = BodyDef();
    bodyDef
      ..position = position
      ..type = BodyType.STATIC
      ..setUserData(this); // To be able to determine object in collision

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class PlanetContactCallback extends ContactCallback<Spaceship, Planet> {
  @override
  void begin(Spaceship spaceship, Planet planet, Contact contact) {
    spaceship.isSpectating = true;
    print(
        'spaceship ${spaceship.id} crashed into planet ${planet.spaceshipId}');
  }

  @override
  void end(Spaceship spaceship, Planet planet, Contact contact) {}
}
