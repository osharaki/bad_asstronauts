import 'package:cloud_functions/cloud_functions.dart';

Future<HttpsCallableResult<dynamic>> triggerBoxPosUpdate() async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateBoxPosition');
  return callable();
}
