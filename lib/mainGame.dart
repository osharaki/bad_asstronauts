import 'dart:ui';
import 'dart:math';

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

import 'components/player.dart';
import 'components/planet.dart';
import 'components/spaceship.dart';
import 'components/planetAtmosphere.dart';

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

  // double resources = 10000;

  // storeRate being twice the harvest rate provides home field (sadeeq) advantage
  double storeRate = 0.2;
  double harvestRate = 0.1;

  int latestRespawnTime = 0;

  // {"playerId": {"spaceship": Spaceship(), "planet": Planet()}}
  Map<String, dynamic> players = {};

  Planet centralPlanet;

  Spaceship egoSpaceship;

  JoystickComponent joystick;

  MainGame({this.launcher, this.viewportSize})
      : super(
          gravity: Vector2.zero(),
        ) {
    addContactCallback(planetAtmosphereContactCallback);
    addContactCallback(planetContactCallback);

    imageList = images.loadAll([
      "spaceship.png",
      "moon.png",
      "generic_planet1.png",
    ]);

    initializeJoystick();

    // Not passing game.size directly because atthis point, size is still Vector2.zero(). See https://pub.dev/documentation/flame/1.0.0-rc2/game_base_game/BaseGame/size.html
    // add(MyCircle(this, 10));
  }

  // Without refreshing Joystick, it is only responsive during the FIRST game of the session. After that the Joystick will be unresponsive.
  void initializeJoystick() {
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
  }

  void destroyJoystick() {
    remove(joystick);
    joystick = null;
  }

  // Initialize Game Components
  Future<void> startGame() async {
    initializeJoystick();
    List<Image> images = await imageList;

    centralPlanet = Planet(
      game: this,
      image: images[2],
      spaceshipId: null,
      size: Vector2(10, 10), // used to be 268, 268
      position: Vector2.zero(),
      resources: 1000,
    );

    add(centralPlanet);
    addPlayers(images: images, centralPlanet: centralPlanet);
    print("START GAME: $players");
  }

  // Destroy Game Components
  void endGame() {
    destroyJoystick();
    if (centralPlanet != null) remove(centralPlanet);
    removePlayers();
    print("END GAME: $players");
  }

  // Destroy Game Components, the re-initalize, to ensure freshness
  /* void refreshGame() async {
    await endGame();
    await startGame();
  } */

  // Add specified players to Game. All in session would be added, if no players specified.
  void addPlayers(
      {Map<String, dynamic> playersList, List<Image> images, Planet centralPlanet}) async {
    // TODO restore
    // if (playersList == null) playersList = launcher.serverHandler.serverData["players"];
    playersList = {'1': null, '2': null, '3': null};

    // Calculate home planet init positions using equation of the circle in parametric form
    double distFromSurface = 100; // distance of homeplanets from central planet surface
    double r = centralPlanet.size.x / 2 + distFromSurface;
    double angle = (2 * pi) / playersList.length;

    int i = 0;
    playersList.forEach((player, info) {
      Vector2 planetPosition = Vector2(
        centralPlanet.position.x + r * cos(angle * i),
        centralPlanet.position.y + r * sin(angle * i),
      );
      addPlayer(player, images, homePlanetPos: planetPosition);
      i++;
    });
  }

  // Add specified player to Game, and assign Planet & Spaceship
  Future<void> addPlayer(String player, List<Image> images, {Vector2 homePlanetPos}) async {
    Image spaceshipImage = images[0];
    Image planetImage = images[1];

    var planetSize = Vector2(10, 10);

    Planet planet = Planet(
      game: this,
      image: planetImage,
      spaceshipId: player,
      // TODO restore old size
      size: planetSize, // used to be 268, 268
      position: homePlanetPos,
      resources: 0,
    );

    double distFromAtmosphere = 20; // distance of ship from its home planet's surface
    double r = planet.size.x + distFromAtmosphere;
    // TODO calculate ship position and rotation
    var shipPos = Vector2(
      homePlanetPos.x + planet.planetAtmosphere.size.x + distFromAtmosphere,
      homePlanetPos.y,
    );
    /* var shipPos = Vector2(
      centralPlanet.position.x + r * cos(angle * i),
      centralPlanet.position.y + r * sin(angle * i),
    ); */

    // Instantiate Components
    Spaceship spaceship = Spaceship(
      game: this,
      image: spaceshipImage,
      id: player,
      // TODO restore old size
      size: Vector2(254, 512).scaled(0.02), // scale used to be 0.06
      position: shipPos,
      // TODO restore
      // isEgo: player == launcher.serverHandler.id ? true : false,
      isEgo: player == '2' ? true : false,
    );

    // Add Components to game
    addAll([
      spaceship,
      planet,
    ]);

    // Attach spaceship to joystick if ego
    // TODO if (player == launcher.serverHandler.id)
    if (player == '2') {
      joystick.addObserver(spaceship);
      egoSpaceship = spaceship;
    }

    // Store Components in players map
    players[player] = {
      "spaceship": spaceship,
      "planet": planet,
    };
  }

  // Remove specified players from Game. All in session would be removed, if no players specified.
  void removePlayers({Map<String, dynamic> playersList}) {
    if (playersList == null) playersList = Map.from(players);

    playersList.forEach((player, info) {
      removePlayer(player);
    });
  }

  // Remove specified player from Game
  void removePlayer(String player) {
    // Remove Components from game
    Spaceship spaceship = players[player]["spaceship"];
    Planet planet = players[player]["planet"];

    spaceship.destroy();
    planet.destroy();

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

      /* Only send spaceship updates to server if we're alive. 
      Otherwise, client listens for respawnTime updates.
      Once respawnTime hits 0, client resets its position and rotation
      to initial values and server is updated in next tick. */
      if (egoSpaceship.respawnTime == 0) {
        if (latestRespawnTime == 1) {
          latestRespawnTime = 0;
          // TODO: reset own position and angle to proper initial values sent by server at game start
          Vector2 initPos =
              Vector2((launcher.widget.viewportSize / 2).x, (launcher.widget.viewportSize / 2).y);
          egoSpaceship.body.setTransform(initPos, 0);
          egoSpaceship.radAngle = 0;
        }
        updateServer(
          {
            "position": [egoSpaceship.body.position.x, egoSpaceship.body.position.y],
            "angle": egoSpaceship.radAngle,
            "resources": egoSpaceship.resources,
            "respawnTime": egoSpaceship.respawnTime,
          },
        );
      } else
        // It's necessary to keep track of the last respawnTime so that when its value is 0 we can tell whether it just hit 0 or if if's been like that for a while
        latestRespawnTime = egoSpaceship.respawnTime;
    }
  }

  void updateServer(data) {
    // Send Spaceship information to Server
    launcher.serverHandler.sendDataToServer(
      action: "updateSpaceship",
      data: data,
    );
  }

  @override
  void onReceiveDrag(DragEvent drag) {
    if (joystick != null) joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (dynamic player in players.values) {
      resourceDisplayConfig.render(
        canvas,
        player['planet'].resources.toStringAsFixed(2),
        viewport.getWorldToScreen(player['planet'].position),
        anchor: Anchor.center,
      );
    }

    // canvas.drawCircle(Offset(100, 100), 10, Paint()..color = Colors.red);
  }
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
