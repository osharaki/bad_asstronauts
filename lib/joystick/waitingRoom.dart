import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/gameLauncher.dart';

class WaitingRoom extends StatefulWidget {
  final GameLauncherState launcher;

  WaitingRoom({@required this.launcher});

  @override
  WaitingRoomState createState() => WaitingRoomState();
}

class WaitingRoomState extends State<WaitingRoom> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey[900],
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.launcher.game.id == widget.launcher.game.serverData["host"]
                ? Text("HOST")
                : Container(width: 0, height: 0),
            Text(
              widget.launcher.game.serverData["id"],
            ),
            Text(
              "Waiting for ${widget.launcher.remainingPlayers} players...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w100,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            OutlineButton(
              borderSide: BorderSide(color: Colors.red[900]),
              padding: EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 155,
              ),
              highlightColor: Colors.red[900].withAlpha(75),
              highlightedBorderColor: Colors.red[900],
              onPressed: () => widget.launcher.game.leaveSession(),
              child: Text(
                "LEAVE",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w100,
                  color: Colors.red[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
