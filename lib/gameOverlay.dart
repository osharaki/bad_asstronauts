import "package:flutter/material.dart";
import 'gameLauncher.dart';

class GameOverlay extends StatefulWidget {
  final GameLauncherState launcher;

  GameOverlay({@required this.launcher});

  @override
  GameOverlayState createState() => GameOverlayState();
}

class GameOverlayState extends State<GameOverlay> {
  String state = "close";

  void toggleState() {
    setState(() {
      if (state == "close") {
        state = "open";
      } else {
        state = "close";
      }
    });
  }

  void changeState(String newState) {
    setState(() {
      state = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeState("close"),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              state == "open"
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withAlpha(175),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    iconSize: 50,
                    color: Colors.white.withAlpha(200),
                    icon: Icon(
                      state == "close" ? Icons.menu : Icons.arrow_back,
                    ),
                    onPressed: toggleState,
                  ),
                ],
              ),
              state == "open"
                  ? Center(
                      child: SizedBox(
                        width: 400,
                        height: 75,
                        child: OutlineButton(
                          highlightedBorderColor: Colors.red[900],
                          highlightColor: Colors.red[900].withAlpha(75),
                          borderSide: BorderSide(color: Colors.red[900]),
                          onPressed: () => widget.launcher.serverHandler.requestLeaveSession(),
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
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
