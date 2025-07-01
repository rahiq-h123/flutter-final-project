import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacebookAuthService {
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      }
      return null;
    } catch (e) {
      print("Facebook Sign-In Error: $e");
      return null;
    }
  }
}
