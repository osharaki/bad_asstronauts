import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// TODO: This should update a position field in firestorm
Future<HttpsCallableResult<dynamic>> updateBoxPos(
    {@required int screenHeight, @required int screenWidth}) async {
  print('Getting new pos');
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateBoxPosition');
  return callable({"screenWidth": screenWidth, "screenHeight": screenHeight});
}
