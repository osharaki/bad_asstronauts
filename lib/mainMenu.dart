import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'gameLauncher.dart';

class MainMenu extends StatefulWidget {
  final GameLauncherState launcher;

  MainMenu({@required this.launcher});

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  String page = "main";
  TextEditingController codeController = TextEditingController();
  TextEditingController limitController = TextEditingController(text: "1");

  void changePage(String newPage) {
    setState(() {
      page = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changePage("main"),
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
                            changePage("create");
                          } else {
                            widget.launcher.serverHandler
                                .requestCreateSession(int.parse(limitController.text));
                          }
                        },
                      ),
                    )
                  : SizedBox(
                      width: 300,
                      height: 75,
                      child: TextField(
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                        controller: codeController,
                        textAlign: TextAlign.center,
                        inputFormatters: [LengthLimitingTextInputFormatter(4)],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              borderSide: BorderSide(
                                style: BorderStyle.none,
                              )),
                          fillColor: Colors.blueGrey[500],
                          filled: true,
                        ),
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
                            changePage("join");
                          } else {
                            if (codeController.text.length != 0) {
                              widget.launcher.serverHandler.requestJoinSession(codeController.text);
                            } else {
                              widget.launcher.serverHandler.requestJoinRandomSession();
                            }
                          }
                        },
                      ),
                    )
                  : SizedBox(
                      width: 300,
                      height: 75,
                      child: TextField(
                        onSubmitted: (_) {
                          if (limitController.text.isEmpty) limitController.text = "1";
                        },
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                        controller: limitController,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.allow(RegExp("[1-9]")),
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
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
