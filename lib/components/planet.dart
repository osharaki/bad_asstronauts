import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/components/planetSensor.dart';

import '../mainGame.dart';

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

  TextComponent resourceDisplay;
  PlanetSensor planetSensor;
  double resources;

  @override
  int priority = -1;

  Planet(this.game, Image image, this.spaceshipId, this.resources, {this.size, this.position})
      : super(Sprite(image), size) {
    planetSensor = PlanetSensor(game, this, size: size, position: position);
    resourceDisplay = TextComponent(
      resources.toString(),
      config: TextConfig(
        fontSize: 48.0,
        fontFamily: 'Awesome Font',
        textAlign: TextAlign.center,
        color: Colors.black,
      ),
    )..anchor = Anchor.center;

    game.add(planetSensor);
    game.add(resourceDisplay);
  }

  @override
  void update(double dt) {
    super.update(dt);
    resourceDisplay
      ..position = viewport.getWorldToScreen(position)
      ..text = resources.toStringAsFixed(2);
    // if (spaceshipId == '1') print(viewport.getScreenToWorld(resourceDisplay.position));
  }

  /* @override
  void render(Canvas c) {
    TextConfig(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      textAlign: TextAlign.center,
    ).render(
      c,
      resources.toStringAsFixed(2),
      game.viewport.getWorldToScreen(Vector2(position.x, position.y + size.y / 2 + 22)),
      anchor: Anchor.center,
    );
    // As opposed to BodyComponents, calling super.render() first in a SpriteBodyComponent's render method will cause the subsequently rendered text to wobble around as the camera moves. calling it last solves this. This however causes the planet to cover the text!
    super.render(c);
  } */

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