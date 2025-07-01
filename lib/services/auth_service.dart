// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;
//   final _db = FirebaseFirestore.instance;

//   Future<void> registerWithEmail({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//     required String bio,
//   }) async {
//     try {
//       UserCredential userCred = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       String uid = userCred.user!.uid;

//       await _db.collection("users").doc(uid).set({
//         "name": name,
//         "email": email,
//         "phone": phone,
//         "bio": bio,
//         "uid": uid,
//         "createdAt": Timestamp.now(),
//       });
//     } catch (e) {
//       print("Error registering: $e");
//     }
//   }

//   Future<void> loginWithEmail(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }
// }
