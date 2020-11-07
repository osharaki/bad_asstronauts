import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gameOff2020/boxGame/boxGame.dart';

class FirebaseInit extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final BoxGame game;

  FirebaseInit(this.game);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong!',
              textDirection: TextDirection.ltr,
            ),
          );
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return this.game.widget;
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: Text(
            'Loading...',
            textDirection: TextDirection.ltr,
          ),
        );
      },
    );
  }
}
