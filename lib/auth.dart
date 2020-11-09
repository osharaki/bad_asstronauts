import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> anonymousSignIn() {
  print('Trying authentication 🤞🤞🤞🤞🤞🤞🤞🤞🤞🤞');
  try {
    FirebaseAuth.instance.signInAnonymously().then(
      (UserCredential userCredential) {
        userCredential = userCredential;
        
        return userCredential;
      },
    );
  } on Exception catch (e) {
    print('An authentication error occured!!!!!!!!!!!!!!');
  }
}
