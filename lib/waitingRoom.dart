import "package:flutter/material.dart";
import 'package:gameOff2020/joystick/gameLauncher.dart';

class WaitingRoom extends StatefulWidget {
  final GameLauncherState launcher;

  WaitingRoom({@required this.launcher});

  @override
  WaitingRoomState createState() => WaitingRoomState();
}

class WaitingRoomState extends State<WaitingRoom> {
  List<Widget> createPlayerAvatars(Map<String, dynamic> playersInfo) {
    List<Widget> avatars = [];

    playersInfo.forEach((player, info) {
      int color = int.parse(info["color"]);

      avatars.add(SizedBox(
        width: 105,
        height: 50,
        child: OutlineButton(
          highlightedBorderColor: Color(color),
          borderSide: BorderSide(
            color: Color(color),
            width: player == widget.launcher.serverHandler.id ? 5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () {},
          child: Text(
            info["planet"]["resources"].toString(),
            style: TextStyle(
              fontSize: 20,
              color: Color(color),
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ));

      avatars.add(SizedBox(width: 15));
    });

    return avatars;
  }

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
            widget.launcher.game.launcher.serverHandler.id ==
                    widget.launcher.serverHandler.serverData["host"]
                ? Text(
                    "HOST",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
            Text(
              widget.launcher.serverHandler.serverData["id"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w100,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: createPlayerAvatars(widget.launcher.playersInfo),
            ),
            SizedBox(
              height: 25,
            ),
            widget.launcher.game.launcher.serverHandler.id ==
                    widget.launcher.serverHandler.serverData["host"]
                ? SizedBox(
                    width: 400,
                    height: 75,
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.green),
                      highlightColor: Colors.green,
                      highlightedBorderColor: Colors.green,
                      onPressed: () =>
                          widget.launcher.serverHandler.requestStartSession(),
                      child: Text(
                        "START",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w100,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              height: 50,
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.red[900]),
                highlightColor: Colors.red[900].withAlpha(75),
                highlightedBorderColor: Colors.red[900],
                onPressed: () =>
                    widget.launcher.serverHandler.requestLeaveSession(),
                child: Text(
                  "LEAVE",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w100,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
