import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

CollectionReference game = FirebaseFirestore.instance.collection('game');

Future<HttpsCallableResult<dynamic>> triggerBoxPosUpdate(
    {@required int screenHeight, @required int screenWidth}) async {
  print('Triggering new pos update');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateBoxPosition');
  return callable({"screenWidth": screenWidth, "screenHeight": screenHeight});
}
/* 
Future<void> updateUser() {
  return game
    .doc('position')
    .update({'posX': 'Stokes and Sons'})
    .then((value) => print("User Updated"))
    .catchError((error) => print("Failed to update user: $error"));
} */
