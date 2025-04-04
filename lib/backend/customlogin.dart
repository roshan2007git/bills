import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomLogin {
  Future<UserCredential?> signInWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    try {
      QuerySnapshot usernameSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (usernameSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Username does not exist',
        );
      }

      var userDoc = usernameSnapshot.docs[0];

      String email = userDoc['email'];

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } catch (e) {
      return null;
    }
  }
}
