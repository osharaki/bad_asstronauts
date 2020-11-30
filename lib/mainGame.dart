import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/gestures.dart';
import 'package:flame/text_config.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:forge2d/forge2d.dart';
import 'package:gameOff2020/gameLauncher.dart';

import 'components/planet.dart';
import 'components/planetAtmosphere.dart';
import 'components/player.dart';
import 'components/spaceship.dart';

class MainGame extends Forge2DGame with MultiTouchDragDetector {
  // Allows us to have access to the screen size from the first tick, as opposed to relying on Game's size property which only gets initialized after the first resize.
  final Vector2 viewportSize;
  final GameLauncherState launcher;
  Future<List<Image>> imageList;

  PlanetAtmosphereContactCallback planetAtmosphereContactCallback =
      PlanetAtmosphereContactCallback();
  PlanetContactCallback planetContactCallback = PlanetContactCallback();
  // final MyCircleContactCallback myCircleContactCallback = MyCircleContactCallback();

  final TextConfig resourceDisplayConfig = TextConfig(
    fontSize: 48.0,
    fontFamily: 'BigShouldersStencilDisplay2',
    textAlign: TextAlign.center,
  );
  final Map<String, dynamic> planets = {};

  // double resources = 10000;

  // storeRate being twice the harvest rate provides home field (sadeeq) advantage
  double storeRate = 0.2;
  double harvestRate = 0.1;

  // {"playerId": {"spaceship": Spaceship(), "planet": Planet()}}
  Map<String, dynamic> players = {};

  Spaceship egoSpaceship;
  // Player player;
  // Planet planet1;
  // Planet planet2;

  JoystickComponent joystick = JoystickComponent(
    directional: JoystickDirectional(),
    actions: [
      JoystickAction(
        actionId: 1,
        size: 50,
        margin: const EdgeInsets.all(50),
        color: const Color(0xFF0000FF),
      ),
      JoystickAction(
        actionId: 2,
        size: 50,
        color: const Color(0xFF00FF00),
        margin: const EdgeInsets.only(
          right: 50,
          bottom: 120,
        ),
      ),
      JoystickAction(
        actionId: 3,
        size: 50,
        margin: const EdgeInsets.only(bottom: 50, right: 120),
        enableDirection: true,
      ),
    ],
  );

  MainGame({this.launcher, this.viewportSize})
      : super(
          gravity: Vector2.zero(),
        ) {
    addContactCallback(planetAtmosphereContactCallback);
    addContactCallback(planetContactCallback);
    // addContactCallback(myCircleContactCallback);

    imageList = images.loadAll([
      "spaceship.png",
      "moon.png",
      "generic_planet1.png",
    ]);

    // .then((images) {
    //   Planet p2 = Planet(
    //       game: this,
    //       image: images[2],
    //       spaceshipId: '2',
    //       resources: 0,
    //       size: Vector2(268, 268),
    //       position: Vector2(800, 350));

    //   Planet p1 = Planet(
    //       game: this,
    //       image: images[1],
    //       spaceshipId: '1',
    //       resources: 1000,
    //       size: Vector2(268, 268),
    //       position: Vector2(100, 350));

    //   planets.addAll({
    //     '2': p2,
    //     '1': p1,
    //   });

    // player = Player(this);
    // spaceship = Spaceship(
    //   game: this,
    //   image: images.first,
    //   id: '2',
    //   size: Vector2(254, 512).scaled(0.06),
    //   position: viewportSize / 2,
    // );

    // joystick.addObserver(spaceship);

    // add(BoundingBox(
    //   this,
    //   center: viewportSize.scaled(.5),
    //   width: 1500,
    //   height: 1500,
    // ));

    // add(p1);
    // add(p2);
    // add(spaceship);
    // add(player);
    add(joystick);

    // Not passing game.size directly because atthis point, size is still Vector2.zero(). See https://pub.dev/documentation/flame/1.0.0-rc2/game_base_game/BaseGame/size.html
    // add(MyCircle(this, 10));
  }

  Future<void> startGame() async {
    planetAtmosphereContactCallback = PlanetAtmosphereContactCallback();
    planetContactCallback = PlanetContactCallback();
    addContactCallback(planetAtmosphereContactCallback);
    addContactCallback(planetContactCallback);
    joystick = JoystickComponent(
      directional: JoystickDirectional(),
      actions: [
        JoystickAction(
          actionId: 1,
          size: 50,
          margin: const EdgeInsets.all(50),
          color: const Color(0xFF0000FF),
        ),
        JoystickAction(
          actionId: 2,
          size: 50,
          color: const Color(0xFF00FF00),
          margin: const EdgeInsets.only(
            right: 50,
            bottom: 120,
          ),
        ),
        JoystickAction(
          actionId: 3,
          size: 50,
          margin: const EdgeInsets.only(bottom: 50, right: 120),
          enableDirection: true,
        ),
      ],
    );
    add(joystick);
    await addPlayers();
    print("START GAME: $players");
  }

  Future<void> endGame() async {
    removeContactCallback(planetAtmosphereContactCallback);
    removeContactCallback(planetContactCallback);
    remove(joystick);
    await removePlayers();
    print("END GAME: $players");
  }

  void refreshGame() async {
    await endGame();
    await startGame();
  }

  /// Without refreshing Joystick, it is only responsive during the FIRST game of the session.
  /// After that the Joystick will be unresponsive.
  /// However, this poses another issue, where the planet's gravity overpowers the spaceship's thrust,
  /// which means once you're in the gravitational field, you'll get sucked in. Again, this issue only happens
  /// in post-FIRST games.
  ///
  /// Planet force seems to get stronger every time we play in the same session

  Future<void> addPlayers({Map<String, dynamic> playersList}) async {
    if (playersList == null)
      playersList = launcher.serverHandler.serverData["players"];

    playersList.forEach((player, info) {
      addPlayer(player);
    });
  }

  Future<void> addPlayer(String player) async {
    // Ensure Images are loaded
    List<Image> images = await imageList;

    Image spaceshipImage = images[0];
    Image planetImage = images[1];

    // Instantiate Components
    Spaceship spaceship = Spaceship(
      game: this,
      image: spaceshipImage,
      id: player,
      size: Vector2(254, 512).scaled(0.06),
      position: launcher.widget.viewportSize / 2,
      isEgo: player == launcher.serverHandler.id ? true : false,
    );

    Planet planet = Planet(
      game: this,
      image: planetImage,
      spaceshipId: player,
      size: Vector2(268, 268),
      position: Vector2(100, 350),
      resources: 0,
    );

    // Add Components to game
    addAll([
      spaceship,
      planet,
    ]);

    // Attach spaceship to joystick if ego
    if (player == launcher.serverHandler.id) {
      joystick.addObserver(spaceship);
      egoSpaceship = spaceship;
    }

    // Store Components in players map
    players[player] = {
      "spaceship": spaceship,
      "planet": planet,
    };
  }

  Future<void> removePlayers({Map<String, dynamic> playersList}) async {
    if (playersList == null) playersList = Map.from(players);

    playersList.forEach((player, info) {
      removePlayer(player);
    });
  }

  Future<void> removePlayer(String player) async {
    // Remove Components from game
    Spaceship spaceship = players[player]["spaceship"];
    Planet planet = players[player]["planet"];

    removeAll([
      spaceship,
      planet,
    ]);

    players.removeWhere((playerId, value) => playerId == player);

    if (player == launcher.serverHandler.id) {
      egoSpaceship = null;
    }
  }

  @override
  Color backgroundColor() {
    return Colors.blue[900];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (egoSpaceship != null) {
      cameraFollow(egoSpaceship, horizontal: 0, vertical: 0);

      // Send Spaceship information to Server
      launcher.serverHandler.sendDataToServer(
        action: "updateSpaceship",
        data: {
          "position": [
            egoSpaceship.body.position.x,
            egoSpaceship.body.position.y
          ],
          "angle": egoSpaceship.radAngle,
          "resources": egoSpaceship.resources,
        },
      );
    }
  }

  /* void initialize() {
    joystick.addObserver(spaceship);
    // add(spaceship);
    add(joystick);
  } */

  @override
  void onReceiveDrag(DragEvent drag) {
    if (joystick != null) joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (Planet planet in planets.values) {
      resourceDisplayConfig.render(
        canvas,
        planet.resources.toStringAsFixed(2),
        viewport.getWorldToScreen(planet.position),
        anchor: Anchor.center,
      );
    }

    // canvas.drawCircle(Offset(100, 100), 10, Paint()..color = Colors.red);
  }

  /* @override
  Future<void> onLoad() async {
    print('called onload');
    Image spaceshipImage = await images.load('spaceship.png');
    spaceship = Spaceship(Sprite(spaceshipImage), Vector2(25.4, 51.2));
    initialize();
  } */
}

class MyCircle extends BodyComponent {
  final MainGame game;
  final double radius;

  Vector2 position;

  MyCircle(this.game, this.radius) {
    position = Vector2(game.size.x / 2 + 100, game.size.y / 2);
  }

  /* @override
  void render(Canvas c) {
    super.render(c);
    TextConfig(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      textAlign: TextAlign.center,
    ).render(
      c,
      'Resources',
      game.viewport.getWorldToScreen(position),
      anchor: Anchor.center,
    );
  } */

  @override
  Body createBody() {
    final CircleShape shape = CircleShape();
    shape.radius = radius;
    Vector2 worldPosition = Vector2(position.x, position.y);

    final fixtureDef = FixtureDef()
      ..shape = shape
      ..restitution = 0
      ..density = 1.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..setUserData(this)
      ..position = worldPosition
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MyCircleContactCallback extends ContactCallback<Spaceship, MyCircle> {
  @override
  void begin(Spaceship spaceship, MyCircle circle, Contact contact) {
    spaceship.isSpectating = true;
    print('spaceship ${spaceship.id} crashed into circle');
  }

  @override
  void end(Spaceship spaceship, MyCircle circle, Contact contact) {}
}

class BoundingBox extends BodyComponent {
  final MainGame game;
  final Vector2 center;
  final double width, height;

  BoundingBox(this.game, {this.center, this.width, this.height});

  @override
  Body createBody() {
    // Box edges
    double top = center.y + height / 2;
    double bottom = center.y - height / 2;
    double left = center.x - width / 2;
    double right = center.x + width / 2;

    ChainShape shape = ChainShape()
      ..createLoop([
        Vector2(left, bottom), //bottom-left corner
        Vector2(left, top), // top-left corner
        Vector2(right, top), // top-right corner
        Vector2(right, bottom), // bottom-right corner
      ]);

    final fixtureDef = FixtureDef()
      ..shape = shape
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.1;

    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.white;

    final bodyDef = BodyDef()
      ..setUserData(this) // To be able to determine object in collision
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
