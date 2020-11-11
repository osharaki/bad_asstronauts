import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gameOff2020/boxGame/boxGame.dart';

class FirebaseInit extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  FirebaseInit();

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
          FirebaseFunctions.instance.useFunctionsEmulator(origin: 'http://localhost:5001');
          FirebaseFirestore.instance.settings =
              Settings(host: '10.0.2.2:8080', sslEnabled: false, persistenceEnabled: false);
          var boxGame = BoxGame();
          var tapper = TapGestureRecognizer();
          tapper.onTapDown = boxGame.onTapDown;
          return boxGame.widget;
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
