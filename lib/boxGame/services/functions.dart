import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

Future<HttpsCallableResult<dynamic>> triggerBoxPosUpdate({@required String sessionId}) async {
  // print('Triggering new pos update');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateBoxPosition');
  return callable({"sessionId": sessionId});
}

Future<HttpsCallableResult<dynamic>> triggerScoreIncrement(
    {@required String sessionId, @required String playerId}) async {
  print('Incrementing score');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('incrementScore');
  return callable({"sessionId": sessionId, "playerId": playerId});
}

Future<HttpsCallableResult<dynamic>> triggerSessionInitialization(
    {@required String sessionId}) async {
  print('Initializing session');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('initializeSession');
  return callable({"sessionId": sessionId});
}

Future<HttpsCallableResult<dynamic>> triggerGameStart({@required String sessionId}) async {
  print('Starting game..');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('startGame');
  return callable({"sessionId": sessionId});
}

Future<HttpsCallableResult<dynamic>> triggerGameEnd(
    {@required String sessionId, @required String culpritId}) async {
  print('End game..');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('endGame');
  return callable({"sessionId": sessionId, "culpritId": culpritId});
}
