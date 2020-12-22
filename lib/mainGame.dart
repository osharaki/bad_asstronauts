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
import 'package:bad_asstronauts/gameLauncher.dart';

import 'components/player.dart';
import 'components/planet.dart';
import 'components/spaceship.dart';
import 'components/planetAtmosphere.dart';

class MainGame extends Forge2DGame with MultiTouchDragDetector {
  // Allows us to have access to the screen size from the first tick, as opposed to relying on Game's size property which only gets initialized after the first resize.
  final Vector2 viewportSize;
  final GameLauncherState launcher;
  final double respawnResources = 20;
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

  final TextConfig gameTimerConfig = TextConfig(
    fontSize: 24.0,
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
      "spaceship_invisible.png",
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
      priority: 100,
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
    if (joystick != null) remove(joystick);
    joystick = null;
  }

  // Initialize Game Components
  Future<void> startGame() async {
    initializeJoystick();
    List<Image> images = await imageList;

    centralPlanet = Planet(
      game: this,
      image: images[3],
      spaceshipId: null,
      size: Vector2(268, 268), // used to be 268, 268
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
    if (playersList == null) playersList = launcher.serverHandler.serverData["players"];

    // Calculate home planet init positions using equation of the circle in parametric form
    double distFromSurface = 500; // distance of homeplanets from central planet surface
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
    Image planetImage = images[2];

    var planetSize = Vector2(268, 268);

    Planet planet = Planet(
      game: this,
      image: planetImage,
      spaceshipId: player,
      size: planetSize,
      position: homePlanetPos,
      resources: 0,
    );

    double distFromAtmosphere = 150; // distance of ship from its home planet's surface
    double distFromPlanetCenter = planet.planetAtmosphere.size.x / 2 + distFromAtmosphere;

    Vector2 centralPlanetDirection = centralPlanet.position - planet.position;
    Vector2 shipPos = planet.position +
        (centralPlanetDirection / centralPlanetDirection.length).scaled(distFromPlanetCenter);
    double shipRotation = atan2(centralPlanetDirection.y * -1, centralPlanetDirection.x);

    // Instantiate Components
    Spaceship spaceship = Spaceship(
      game: this,
      image: spaceshipImage,
      imageInvisible: images[1],
      id: player,
      size: Vector2(254, 512).scaled(0.06),
      position: shipPos,
      initRotation: shipRotation,
      isEgo: player == launcher.serverHandler.id ? true : false,
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

    if (spaceship != null) spaceship.destroy();
    if (planet != null) planet.destroy();

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
          egoSpaceship.body.setTransform(egoSpaceship.position, 0);
          egoSpaceship.radAngle = egoSpaceship.initRotation;
          egoSpaceship.resources = respawnResources;
        }
        if (launcher.state == "playing")
          updateServer(
            {
              "position": [egoSpaceship.body.position.x, egoSpaceship.body.position.y],
              "angle": egoSpaceship.radAngle,
              "resources": egoSpaceship.resources,
              "respawnTime": egoSpaceship.respawnTime,
              "resourceReplenishRate": egoSpaceship.resourceReplenishRate,
              "resourceCriticalThreshold": egoSpaceship.resourceCriticalThreshold,
              "inOrbit": egoSpaceship.inOrbit,
              "currentSpeed": egoSpaceship.currentSpeed,
              "thrust": egoSpaceship.move,
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
    if (launcher.serverHandler.serverData["remainingTime"] != null)
      gameTimerConfig.render(
          canvas,
          launcher.convertMillisecondsToTime(launcher.serverHandler.serverData["remainingTime"]),
          Vector2(viewportSize.x - 200, 30),
          anchor: Anchor.topLeft);

    if (centralPlanet != null)
      resourceDisplayConfig.render(
        canvas,
        centralPlanet.resources.toStringAsFixed(1),
        viewport.getWorldToScreen(centralPlanet.position),
        anchor: Anchor.center,
      );

    for (dynamic player in players.values) {
      resourceDisplayConfig.render(
        canvas,
        player['planet'].resources.toStringAsFixed(1),
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
    spaceship.respawnTime = spaceship.game.launcher.respawnTime;
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
