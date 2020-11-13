import "dart:ui";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gameOff2020/auth.dart';
import 'package:gameOff2020/boxGame/services/functions.dart';

import 'box.dart';
import "dart:math";
import 'package:flame/time.dart';
import "package:flame/game.dart";
import "package:flame/flame.dart";
import 'package:flame/anchor.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import "package:flutter/gestures.dart";
import 'package:flame/text_config.dart';
import 'package:vibration/vibration.dart';
import 'package:gameOff2020/utils/math.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoxGame extends Game with TapDetector {
  //Auth
  bool signedIn = false;

  // UI
  Box box;

  // Gameplay
  int score = 0;
  int opponentScore = 0;
  Timer interval;
  int timeLimit;
  bool playing = false;
  bool started = false;
  bool ready = false;

  // Modes
  String mode = "game";
  String level = "easy";

  // Spacial
  Size screenSize;
  double tileSize;

  // Variables
  var random = Random();

  // Text Configs
  var textConfig = TextConfig(
    color: Colors.white,
    textAlign: TextAlign.center,
  );
  var loseTextConfig = TextConfig(
    color: Colors.red,
    fontSize: 50,
    textAlign: TextAlign.center,
  );

  var scoreTextConfig = TextConfig(
    color: Colors.blue[900],
    fontSize: 20,
    textAlign: TextAlign.center,
  );

  var opponentScoreTextConfig = TextConfig(
    color: Colors.red[900],
    fontSize: 20,
    textAlign: TextAlign.center,
  );

  String sessionId;

  DocumentReference playerInstance;
  DocumentReference opponentInstance;

  UserCredential userCred;

  String winnerId;

  String gameStartCountdown;

  // QueryDocumentSnapshot activeSession;

  BoxGame() {
    initialize();
  }

  void initialize() async {
    // Auth
    FirebaseAuth.instance.authStateChanges().listen(
      (User user) {
        if (user == null) {
          print('❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗');
          print('User currently signed out');
          signedIn = false;
        } else {
          print('✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️✔️');
          print('User signed in!');
          signedIn = true;
        }
      },
    );
    resize(await Flame.util.initialDimensions());

    box = Box(
      game: this,
    );

    /* interval = Timer(
      1,
      repeat: true,
      callback: () => timeLimit -= 1,
    );

    interval.start(); */
  }

  @override
  void render(Canvas canvas) {
    // Paint BG
    Rect bgRect = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height,
    );
    Paint bgPaint = Paint();
    bgPaint.color = Colors.black;

    canvas.drawRect(bgRect, bgPaint);

    if (box != null) box.render(canvas);

    if (!signedIn) {
      textConfig.render(
        canvas,
        "TAP TO JOIN A GAME",
        Position(
          screenSize.width / 2,
          screenSize.height / 2 - 70,
        ),
        anchor: Anchor.center,
      );
    } else {
      // Start
      if (!playing) {
        if (!ready) {
          textConfig.render(
            canvas,
            "WAITING FOR RIVAL",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 70,
            ),
            anchor: Anchor.center,
          );
          TextConfig(
            fontSize: 20,
            color: Colors.white,
            textAlign: TextAlign.center,
          ).render(
            (canvas),
            "tap outside to sign out",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 + 60,
            ),
            anchor: Anchor.center,
          );
        } else {
          textConfig.render(
            canvas,
            gameStartCountdown,
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 90,
            ),
            anchor: Anchor.center,
          );
          TextConfig(
            fontSize: 20,
            color: Colors.white,
            textAlign: TextAlign.center,
          ).render(
            (canvas),
            "GAME STARTS IN...",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 120,
            ),
            anchor: Anchor.center,
          );
        }
        // Playing
      } else if (playing) {
        // If Time
        if (timeLimit > 0) {
          // Your Score
          scoreTextConfig.render(
            canvas,
            score.toString(),
            Position(
              (screenSize.width / 2) - 25,
              screenSize.height - 50,
            ),
            anchor: Anchor.bottomRight,
          );

          // Separator
          textConfig.render(
            canvas,
            "|",
            Position(
              screenSize.width / 2,
              screenSize.height,
            ),
            anchor: Anchor.center,
          );

          // Opponent Score
          opponentScoreTextConfig.render(
            canvas,
            opponentScore.toString(),
            Position(
              (screenSize.width / 2) + 25,
              screenSize.height - 50,
            ),
            anchor: Anchor.bottomLeft,
          );

          textConfig.render(
            canvas,
            timeLimit.toStringAsFixed(0),
            Position(
              screenSize.width / 2,
              50,
            ),
            anchor: Anchor.topCenter,
          );

          // If Time's Up
        }
        /* else {
          // TODO: MOVE TO update()

          // Stop Playing
          playing = false;
          sessionId.then((sessionId) => triggerGameEnd(sessionId: sessionId));

          // box.updatePosition(reset: true);
        }
 */
        // Retry
      } else {
        /* if (timeLimit > 0) {
          loseTextConfig.render(
            canvas,
            "YOU LOST!",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 125,
            ),
            anchor: Anchor.center,
          );
        } else {
          loseTextConfig.render(
            canvas,
            "TIME'S UP!",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 125,
            ),
            anchor: Anchor.center,
          );
        } */
        if (winnerId == 'tie') {
          TextConfig(
            color: Colors.white,
            fontSize: 50,
            textAlign: TextAlign.center,
          ).render(
            canvas,
            "TIE!",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 125,
            ),
            anchor: Anchor.center,
          );
        }
        else if (winnerId == userCred.user.uid) {
          TextConfig(
            color: Colors.green,
            fontSize: 50,
            textAlign: TextAlign.center,
          ).render(
            canvas,
            "YOU WIN!",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 125,
            ),
            anchor: Anchor.center,
          );
        } else {
          TextConfig(
            color: Colors.red,
            fontSize: 50,
            textAlign: TextAlign.center,
          ).render(
            canvas,
            "YOU LOST!",
            Position(
              screenSize.width / 2,
              screenSize.height / 2 - 125,
            ),
            anchor: Anchor.center,
          );
        }
        // Your Score
        scoreTextConfig.render(
          canvas,
          score.toString(),
          Position(
            (screenSize.width / 2) - 50,
            (screenSize.height / 2) - 90,
          ),
          anchor: Anchor.center,
        );

        // Separator
        textConfig.render(
          canvas,
          "|",
          Position(
            screenSize.width / 2,
            screenSize.height,
          ),
          anchor: Anchor.center,
        );

        // Opponent Score
        opponentScoreTextConfig.render(
          canvas,
          opponentScore.toString(),
          Position(
            (screenSize.width / 2) + 50,
            (screenSize.height / 2) - 90,
          ),
          anchor: Anchor.center,
        );

        textConfig.render(
          canvas,
          "TAP BOX TO REPLAY",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 + 100,
          ),
          anchor: Anchor.center,
        );
        TextConfig(
          fontSize: 20,
          color: Colors.white,
          textAlign: TextAlign.center,
        ).render(
          (canvas),
          "tap outside to sign out",
          Position(
            screenSize.width / 2,
            screenSize.height / 2 + 130,
          ),
          anchor: Anchor.center,
        );
      }
    }
  }

  @override
  void update(double t) {
    box.update(t);

    // if (playing) {
    //   interval.update(t);
    // }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.height / 9;
  }

  void onTapDown(TapDownDetails details) async {
    if (box.rect.contains(details.globalPosition)) {
      if (!signedIn) {
        bool joinedSession = false;
        print('USER TAPPED TO SIGN IN 🤏🤏🤏🤏🤏🤏🤏🤏');
        userCred = await anonymousSignIn();
        CollectionReference sessions = FirebaseFirestore.instance.collection('sessions');
        sessions.get().then(
          (sessionsQuerySnapshot) async {
            if (sessionsQuerySnapshot.docs.isNotEmpty) print('*' * 20);
            for (final session in sessionsQuerySnapshot.docs) {
              print('Found session. Checking availability...');
              CollectionReference playersCollection = session.reference.collection('players');
              QuerySnapshot playersQuerySnapshot = await playersCollection.get();
              if (playersQuerySnapshot.docs.length == 1) {
                print('*' * 20);
                print('Session available');
                print('Joining...');
                opponentInstance = playersQuerySnapshot.docs[0].reference;
                opponentScore = playersQuerySnapshot.docs[0].data()['score'];
                await playersCollection.doc(userCred.user.uid).set({'score': 0});
                print('Joined session ${session.reference.id}');
                joinedSession = true;
                sessionId = session.reference.id;
                break;
              }
              print('Session full.');
            }
            if (!joinedSession) {
              print('*' * 20);
              print('No sessions available');
              print('Creating session and joining..');
              sessionId = await sessions.add({}).then((DocumentReference session) async {
                await triggerSessionInitialization(sessionId: session.id);
                QuerySnapshot sessions =
                    await FirebaseFirestore.instance.collection('sessions').get();
                for (final sessionQuery in sessions.docs) {
                  if (session.id == sessionQuery.id) timeLimit = sessionQuery.data()['time'];
                }
                playerInstance = session.collection('players').doc(userCred.user.uid);
                playerInstance.set({'score': 0});
                print('Joined newly created session with id ' + session.id);
                return session.id;
              });
            }

            String activeSessionId = await sessionId;
            FirebaseFirestore.instance
                .collection('sessions')
                .doc(activeSessionId)
                .snapshots()
                .listen((activeSession) async {
              // print('Position change detected!!!!!!');
              if (activeSession.exists) {
                Map<String, dynamic> sessionData = activeSession.data();
                if (sessionData != null) {
                  if (sessionData['boxPosition'] == null) {
                    print('😢😢😢😢😢😢😢😢😢😢😢😢😢😢😢😢😢');
                    print(sessionData);
                  }
                  timeLimit = sessionData['time'];
                  QuerySnapshot players = await activeSession.reference.collection('players').get();
                  for (final player in players.docs) {
                    if (player.id == userCred.user.uid)
                      score = player.data()['score'];
                    else
                      opponentScore = player.data()['score'];
                  }
                  box.updatePosition(positionFromServer: {
                    'posX': sessionData['boxPosition']['posX'],
                    'posY': sessionData['boxPosition']['posY']
                  });
                  // started = sessionData['started'];
                  playing = sessionData['started'];
                  winnerId = sessionData['winner'];
                  ready = sessionData['ready'];
                  gameStartCountdown = sessionData['startCountdown'].toString();
                } else {
                  box.updatePosition(positionFromServer: {'posX': 50, 'posY': 50});
                  playing = false;
                  playerInstance = null;
                  opponentInstance = null;
                  sessionId = null;
                  score = 0;
                  opponentScore = 0;
                  winnerId = null;
                  ready = false;
                  gameStartCountdown = null;
                }
              }
            });
          },
        );
      } else {
        // Randomize Position
        // updatePosition();
        // increment score
        // Update firestore position field every time player taps box
        if (sessionId != null) {
          if (sessionId == null) print('😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱');
          // triggerGameStart(sessionId: sessionId);
          triggerBoxPosUpdate(sessionId: sessionId);
          triggerScoreIncrement(sessionId: sessionId, playerId: userCred.user.uid);
          // Start Game
          // if (!playing) {
          //   // started = true;
          //   triggerGameStart(sessionId: sessionId);
          // }

          // Box On Tap Down
          box.onTapDown(details);
        }
      }
    } else {
      if (signedIn) {
        if (playing) {
          // Vibration
          if (await Vibration.hasAmplitudeControl()) {
            Vibration.vibrate(
              duration: 1000,
              amplitude: 125,
            );
          } else if (await Vibration.hasVibrator()) {
            Vibration.vibrate(duration: 1000);
          }

          // Reset Box Position & Color
          // box.updatePosition(reset: true);
          box.paint.color = Colors.white;

          // Stop Playing
          // playing = false;
          triggerGameEnd(sessionId: sessionId, culpritId: userCred.user.uid);
        } else {
          // sign out if tapped outside box while not playing
          // remove player from session
          if (playerInstance != null) {
            playerInstance.delete().then((value) => print('Deleted player document!!!!!!!!!'));
          }

          //
          FirebaseAuth.instance.currentUser.delete();
          opponentInstance = null;
          playerInstance = null;
          sessionId = null;
          winnerId = null;
          ready = false;
          // started = false;
        }
      }
    }
/*     print(sessionId);
    print(playerInstance);
    print(started); */
  }
}
