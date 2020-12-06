import 'dart:ui';
import 'dart:convert';

import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart' hide Image;

import 'gameLauncher.dart';
import 'components/planet.dart';
import 'components/spaceship.dart';

// TODO: Enforce Session Limit

class ServerHandler {
  String id;
  List<Image> imageList;
  Map<String, dynamic> serverData = {};

  GameLauncherState launcher;

  Map<String, Map<String, dynamic>> players = {};

  ServerHandler({@required this.launcher}) {
    launcher.channel.stream.listen((rawMessage) => onReceiveMessage(rawMessage));
  }

  void requestCreateSession(int limit) {
    Map<String, dynamic> createData = {
      "action": "create",
      "data": {
        "host": id,
        "limit": limit,
        "time": 15000,
        "remainingTime": 15000,
        "respawnTime": launcher.respawnTime,
        "state": "creating",
        "players": {},
      },
    };

    launcher.channel.sink.add(json.encode(createData));
  }

  void requestJoinSession(String session) {
    Map<String, dynamic> joinData = {
      "action": "join",
      "data": {"session": session},
    };

    launcher.channel.sink.add(json.encode(joinData));
  }

  void requestJoinRandomSession() {
    Map<String, dynamic> joinRandomData = {
      "action": "joinRandom",
      "data": null,
    };

    launcher.channel.sink.add(json.encode(joinRandomData));
  }

  void requestLeaveSession() {
    Map<String, dynamic> leaveData = {
      "action": "leave",
      "data": {"session": serverData["id"]},
    };

    launcher.channel.sink.add(json.encode(leaveData));
  }

  void requestStartSession() {
    Map<String, dynamic> startData = {
      "action": "start",
      "data": {"session": serverData["id"]},
    };

    launcher.channel.sink.add(json.encode(startData));
  }

  void addPlayer(String player) {
    players[player] = {
      "spaceship": null,
      "planet": null,
    };
  }

  void addPlayers() {
    serverData["players"].keys.forEach((player) {
      if (!players.containsKey(player)) {
        players[player] = {
          "spaceship": null,
          "planet": null,
        };
      }
    });
  }

  /* void initializeGame() {
    launcher.game.refreshGame();
  } */

  void removePlayer(String player) {
    // TODO: Earlier players see later players right off the bat, but later players can only see earlier players when they move. Why? Must be some information being sent to people already in session. Make sure to add people THEN update the info.

    players.remove(player);
  }

  void leaveSession() {
    serverData.clear();
    launcher.updateState("out");
  }

  void updateLocalSpaceship(String player, Map<String, dynamic> data) {
    double angle = data["angle"].toDouble();
    double resources = data["resources"].toDouble();
    Vector2 position = Vector2(
      data["position"][0].toDouble(),
      data["position"][1].toDouble(),
    );
    bool isSpectating = data["isSpectating"];

    serverData["players"][player]["spaceship"] = data;

    launcher.game.players[player]["spaceship"].isSpectating = isSpectating;

    if (player != id) {
      if (launcher.game.players.containsKey(player)) {
        launcher.game.players[player]["spaceship"].body.setTransform(position, 0.0);
        launcher.game.players[player]["spaceship"].radAngle = angle;
        launcher.game.players[player]["spaceship"].resources = resources;
      }
    }
  }

  void updateLocalPlanet(String player, Map<String, dynamic> data) {
    int resources = data["resources"];

    serverData["players"][player]["planet"]["resources"] = resources;

    // TODO: Plug information into Planet class
  }

  void updatePlayers() {
    // if (serverData["state"] == "playing") {
    //   players.keys.forEach((player) {
    //     dynamic angle = serverData["players"][player]["spaceship"]["angle"];

    //     Offset position = launcher.game.getWorldPositionFromPercent(
    //         serverData["players"][player]["spaceship"]["position"]);

    //     Offset planetPosition = launcher.game.getWorldPositionFromPercent(
    //         serverData["players"][player]["planet"]["position"]);

    //     // Update info
    //     players[player]["spaceship"].worldPosition = position;
    //     players[player]["spaceship"].angle = angle.toDouble();

    //     players[player]["planet"].position = planetPosition;
    //   });
    // }
  }

  void sendDataToServer({
    @required String action,
    @required Map<String, dynamic> data,
  }) {
    String message = jsonEncode({"action": action, "data": data});
    launcher.channel.sink.add(message);
  }

  void onReceiveMessage(String rawMessage) {
    // {"action": <actionName>, "data": {<field>: <value>}}
    Map message = jsonDecode(rawMessage);
    String action = message["action"];
    Map<String, dynamic> data = message["data"];

    // ACTIONS
    // Connect
    if (action == "connect") {
      // Store ID
      id = data["id"];

      // Update
    } else if (action == "update") {
      serverData = data["info"];
      updatePlayers();

      // Player Joined
    } else if (action == "playerJoined") {
      serverData = data["info"];
      String player = data["player"];

      launcher.updatePlayersInfo(serverData["players"]);
      addPlayers();

      if (player == id) {
        launcher.updateState("waiting");
      }

      // Player Left
    } else if (action == "playerLeft") {
      serverData = data["info"];

      removePlayer(data["player"]);
      launcher.updatePlayersInfo(serverData["players"]);

      // Session State Changed
    } else if (action == "stateChanged") {
      String state = data["state"];

      if (state == "playing") {
        launcher.game.startGame();
      } else if (state == "waiting") {
        launcher.game.endGame();
        launcher.updatePlayersInfo(serverData["players"]);
      }

      launcher.updateState(state);

      // Joined Wrong Session
    } else if (action == "wrongSession") {
      print("WRONG SESSION!");

      // You left
    } else if (action == "youLeft") {
      leaveSession();

      // Session Terminated
    } else if (action == "sessionTerminated") {
      print("HOST ENDED SESSION");

      // No Sessions Available
    } else if (action == "noSessions") {
      print("NO SESSIONS AVAILABLE");

      // Time Updated
    } else if (action == "timeUpdated") {
      // TODO: Screen flickers on time tick
      serverData["remainingTime"] = data["remainingTime"];
      launcher.updateRemainingTime();

      // Session Reset
    } else if (action == "sessionReset") {
      serverData = data["info"];
      // initializeGame();
      updatePlayers();

      // Spaceship updated
    } else if (action == "spaceshipUpdated") {
      // {"player":<id>, "info": {"position":[50, 50], "angle":10, "resources":100}}
      String player = data["player"];
      Map<String, dynamic> info = data["info"];

      updateLocalSpaceship(player, info);

      // Planet Updated
    } else if (action == "planetUpdated") {
      String player = data["player"];
      Map<String, dynamic> info = data["info"];

      updateLocalPlanet(player, info);
    } else if (action == "respawnTimerUpdated") {
      print(data);
      int respawnTime = data['respawnTime'];
      launcher.game.players[id]["spaceship"].respawnTime = respawnTime;
    }
  }

  int getRemainingPlayers() {
    int sessionLimit = serverData["limit"];
    int currentPlayerCount = serverData["players"].keys.length;
    int remainingPlayers = sessionLimit - currentPlayerCount;

    return remainingPlayers;
  }

  void update(double t) {
    // Planets
    players.keys.forEach((player) {
      players[player]["planet"].update(t);
    });

    // Spaceships
    players.keys.forEach((player) {
      players[player]["spaceship"].update(t);
    });
  }

  void render(Canvas canvas) {
    // Planets
    players.keys.forEach((player) {
      players[player]["planet"].render(canvas);
    });

    // Spaceships
    players.keys.forEach((player) {
      players[player]["spaceship"].render(canvas);
    });
  }
}
