import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> anonymousSignIn() {
  print('Trying authentication 🤞🤞🤞🤞🤞🤞🤞🤞🤞🤞');
  Future<UserCredential> userCredential =
      FirebaseAuth.instance.signInAnonymously().then((value) => value);
  return userCredential;
}
