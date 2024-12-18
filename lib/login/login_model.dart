import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../user/shared_preferences.dart';



class LoginModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? email;
  String? password;

  bool isLoading = false;

  bool isObscure = true;

  void obscureChange() {
    isObscure =! isObscure;
    notifyListeners();
  }

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

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  Future login() async {
    email = emailController.text;
    password = passwordController.text;

    if (email != null && password != null) {
      //ログイン
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!
      );

      final user = userCredential.user;
      final uid = user!.uid;
      saveUserData(uid);

      notifyListeners();
    }
  }
}
