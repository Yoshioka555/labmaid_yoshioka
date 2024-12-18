import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login/login_page.dart';
import 'reset_password_model.dart';

//エラーを表示
String? error;

class ResetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResetPasswordModel>(
      create: (_) => ResetPasswordModel(),
      child: Theme(
        data: ThemeData(
          useMaterial3: true, // Material 3 を有効化
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
        ),
        child: Scaffold(
          //appBar: AppBar(title: Text('パスワードリセット'),),
          body: Consumer<ResetPasswordModel>(builder: (context, model, child) {
            return Center(
              child: Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 5,
                      blurRadius: 30,
                      offset: Offset(1, 1),
                    ),
                  ],
                  color: Colors.white,
                ),
                height: 600,
                width: 400,
                child: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                            height: 50,
                            child: Image(
                                image: AssetImage(
                                    'assets/images/al_logo_cleaned.png'))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.clear)),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                            children: [
                              /*
                              SizedBox(
                                  height: 70,
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/al_logo.png'))),
                              SizedBox(height: 30),
                              */
                              const Text(
                                'パスワードリセット',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'パスワードリセットの案内メールを送信します。\n送信先のメールアドレスを入力してください。',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: model.emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Your Email',
                                  icon: Icon(Icons.mail),
                                ),
                                onChanged: (text) {
                                  model.setEmail(text);
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(200, double.infinity),
                                    backgroundColor: Colors.black, //ボタンの背景色
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                  ),
                                  onPressed: () async {
                                    model.startLoading();
                                    try {
                                      await model.sendPasswordResetEmail();
                                      final snackBar = SnackBar(
                                        backgroundColor: Colors.blue,
                                        content:
                                        Text('${model.email}にメールを送信しました'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      //現在の画面をナビゲーションスタックから取り除き、新しい画面をプッシュできる
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const LoginPage()),
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      //ユーザーログインに失敗した場合
                                      if (e.code == 'user-not-found') {
                                        error = 'ユーザーは存在しません';
                                      } else if (e.code == 'invalid-email') {
                                        error = 'メールアドレスの形をしていません';
                                      } else {
                                        error = 'メールを送信できません';
                                      }

                                      final snackBar = SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(error.toString()),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } finally {
                                      model.endLoading();
                                    }
                                  },
                                  child: const Text(
                                    'リセットメールを送信',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (model.isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}