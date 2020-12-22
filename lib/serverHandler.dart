import 'dart:ui';
import 'dart:convert';

import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart' hide Image;

import 'gameLauncher.dart';

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
        "time": 60000,
        "remainingTime": 60000,
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

  void removePlayer(String player) {
    // TODO: Earlier players see later players right off the bat, but later players can only see earlier players when they move. Why? Must be some information being sent to people already in session. Make sure to add people THEN update the info.

    players.remove(player);
  }

  void leaveSession() {
    serverData.clear();
    launcher.updateState("out");
  }

  void updateLocalSpaceship(String player, Map<String, dynamic> data) {
    // null checks are important especially for first couple of server updates
    // when it still hasn't received any data from the client.
    double angle = data["angle"] != null ? data["angle"].toDouble() : null;
    double resources = data["resources"] != null ? data["resources"].toDouble() : null;
    Vector2 position = data["position"] != null
        ? Vector2(
            data["position"][0].toDouble(),
            data["position"][1].toDouble(),
          )
        : null;
    serverData["players"][player]["spaceship"] = data;
    if (resources != null) launcher.game.players[player]["spaceship"].resources = resources;
    if (player != id) {
      if (launcher.game.players.containsKey(player)) {
        if (position != null)
          launcher.game.players[player]["spaceship"].body.setTransform(position, 0.0);
        if (angle != null) launcher.game.players[player]["spaceship"].radAngle = angle;
      }
    }
  }

  void updateLocalPlanet(String player, Map<String, dynamic> data) {
    int resources = data["resources"];

    serverData["players"][player]["planet"]["resources"] = resources;

    players[player]["planet"].resources = resources;
  }

  void sendDataToServer({
    @required String action,
    @required Map<String, dynamic> data,
  }) {
    String message = jsonEncode({"action": action, "data": data});
    launcher.channel.sink.add(message);
  }

  void onReceiveMessage(String rawMessage) {
    Map message = jsonDecode(rawMessage);
    String action = message["action"];
    Map<String, dynamic> data = message["data"];

    if (action == "connect")
      id = data["id"];
    else if (action == "update")
      serverData = data["info"];
    else if (action == "playerJoined") {
      serverData = data["info"];
      String player = data["player"];

      launcher.updatePlayersInfo(serverData["players"]);
      addPlayers();

      if (player == id) launcher.updateState("waiting");
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
    } else if (action == "wrongSession")
      print("WRONG SESSION!");
    else if (action == "youLeft")
      leaveSession();
    else if (action == "sessionTerminated")
      print("HOST ENDED SESSION");
    else if (action == "noSessions")
      print("NO SESSIONS AVAILABLE");
    else if (action == "timeUpdated")
      serverData["remainingTime"] = data["remainingTime"];
    else if (action == "sessionReset")
      serverData = data["info"];
    else if (action == "gameUpdated") {
      dynamic spaceshipsUpdate = data['spaceships'];
      print(spaceshipsUpdate);
      spaceshipsUpdate.forEach((playerID, spaceshipData) {
        updateLocalSpaceship(playerID, spaceshipData);
      });

      // TODO use planet update data
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
