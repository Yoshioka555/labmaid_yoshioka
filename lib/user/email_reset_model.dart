import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../network/url.dart';

class EmailResetModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  String userId = '';
  int? id;
  String initialEmail = '';

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void fetchEmailReset() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    userId = uid;
    emailController.text = '';
    initialEmail = user.email!;
    var uri = Uri.parse('${httpUrl}user_id/$userId');
    var response = await http.get(uri);
    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      id = responseData['id'];

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }

    notifyListeners();
  }

  bool isValidEmail(String email) {
    // 正規表現パターン
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);

    return regExp.hasMatch(email);
  }

  //ユーザ情報更新
  Future<void> updateUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(email: user!.email!, password: passwordController.text);
    String email = emailController.text;

    if (initialEmail == emailController.text) {
      throw 'メールアドレスが変更されていません。';
    }

    if (emailController.text == '') {
      throw 'メールアドレスが入力されていません。';
    }

    if (!isValidEmail(emailController.text)) {
      throw 'メールアドレスの形をしていません。';
    }

    try {
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(email);
      await updateEmailFastAPI();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw 'パスワードが間違っています';
      } else if (e.code == 'email-already-in-use') {
        throw '既に使われているメールアドレスです。';
      } else if (e.code == 'invalid-email') {
        throw 'メールアドレスまたはパスワードが間違えています。';
      } else if (e.code == 'invalid-credential') {
        throw 'メールアドレスまたはパスワードが間違えています。';
      } else {
        throw '$e';
      }
    } catch (e) {
      throw 'Error updating email $e';
    }

    notifyListeners();
  }

  Future<void> updateEmailFastAPI() async {
    var uri = Uri.parse('${httpUrl}users/email/$id');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'email': emailController.text,
      // 他のキーと値を追加
    };

    // リクエストヘッダーを設定
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON形式のデータを送信する場合
      // 他のヘッダーを必要に応じて追加
    };

    try {
      // HTTP POSTリクエストを送信
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data), // データをJSON形式にエンコード
      );

      // レスポンスをログに出力（デバッグ用）
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }

}