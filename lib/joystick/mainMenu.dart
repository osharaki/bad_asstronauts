import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:gameOff2020/joystick/gameLauncher.dart';

class MainMenu extends StatefulWidget {
  final GameLauncherState launcher;

  MainMenu({@required this.launcher});

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  String page = "main";
  TextEditingController codeController = TextEditingController();
  TextEditingController limitController = TextEditingController();

  void changePange(String newPage) {
    setState(() {
      page = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changePange("main"),
      child: Material(
        color: Colors.blueGrey[900],
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "BAD ASSTRONAUTS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w100,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              ["main", "create"].contains(page)
                  ? SizedBox(
                      width: 400,
                      height: 75,
                      child: OutlineButton(
                        highlightColor: Colors.white.withAlpha(75),
                        highlightedBorderColor: Colors.white,
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                        child: Text(
                          "CREATE",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        onPressed: () {
                          if (page != "create") {
                            changePange("create");
                          } else {
                            widget.launcher.game
                                .createSession(int.parse(limitController.text));
                          }
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      width: 400,
                      height: 75,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 75,
                            child: TextField(
                              controller: codeController,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10)
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    borderSide: BorderSide(
                                      style: BorderStyle.none,
                                    )),
                                fillColor: Colors.blueGrey[500],
                                filled: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.blueGrey[200],
                            ),
                            onPressed: null,
                            iconSize: 50,
                          )
                        ],
                      ),
                    ),
              SizedBox(height: 10),
              ["main", "join"].contains(page)
                  ? SizedBox(
                      width: 400,
                      height: 75,
                      child: OutlineButton(
                        highlightColor: Colors.white.withAlpha(75),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                        child: Text(
                          "JOIN",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        onPressed: () {
                          if (page != "join") {
                            changePange("join");
                          } else {
                            if (codeController.text.length != 0) {
                              widget.launcher.game
                                  .joinSession(codeController.text);
                            } else {
                              widget.launcher.game.joinRandomSession();
                            }
                          }
                        },
                      ),
                    )
                  : SizedBox(
                      width: 300,
                      height: 75,
                      child: TextField(
                        controller: limitController,
                        textAlign: TextAlign.center,
                        inputFormatters: [LengthLimitingTextInputFormatter(1)],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(
                                style: BorderStyle.none,
                              )),
                          fillColor: Colors.blueGrey[500],
                          filled: true,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
