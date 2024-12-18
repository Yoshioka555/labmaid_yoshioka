import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ResetPasswordModel extends ChangeNotifier {
  final emailController = TextEditingController();

  String? email;

  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future sendPasswordResetEmail() async {
    email = emailController.text;

    if (email != null ) {
      await _auth.sendPasswordResetEmail(email: email!);
    }
  }

}
