import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../header_footer_drawer/footer.dart';
import '../register/register_page.dart';
import '../reset_password/reset_password_page.dart';
import 'login_model.dart';

//エラーを表示
String? error;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>(
      create: (_) => LoginModel(),
      child: PopScope(
        canPop: false,
        child: Theme(
          data: ThemeData(
            useMaterial3: true, // Material 3 を有効化
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
          ),
          child: Scaffold(
            body: Consumer<LoginModel>(builder: (context, model, child) {
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
                      Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Column(
                              children: [
                                const SizedBox(
                                    height: 70,
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/al_logo_cleaned.png'))),
                                const SizedBox(height: 30),
                                const Text(
                                  'ログイン',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                /*
                                SizedBox(height: 20),
                                Text(
                                  'Labmaidを利用するためにログインしてください。',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                */
                                const SizedBox(height: 10),
                                TextField(
                                  controller: model.emailController,
                                  cursorColor: Colors.red,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    //メールのアイコン
                                    icon: Icon(Icons.mail),
                                  ),
                                  onChanged: (text) {
                                    model.setEmail(text);
                                  },
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: model.passwordController,
                                  obscureText: model.isObscure,
                                  cursorColor: Colors.red,
                                  // カーソル色
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    //鍵のアイコン
                                    icon: const Icon(Icons.lock),
                                    //目隠しのアイコン
                                    suffixIcon: IconButton(
                                      icon: Icon(model.isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        model.obscureChange();
                                      },
                                    ),
                                  ),
                                  onChanged: (text) {
                                    model.setPassword(text);
                                  },
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        //画面遷移
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ResetPasswordPage(),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                      },
                                      child: const Text('パスワードをお忘れですか？'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(200, double.infinity),
                                      backgroundColor: Colors.black, //ボタンの背景色
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                    ),
                                    //Buttons.Email,
                                    onPressed: () async {
                                      model.startLoading();
                                      //追加の処理
                                      try {
                                        await model.login();
                                        //現在の画面をナビゲーションスタックから取り除き、新しい画面をプッシュできる
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const Footer(
                                                  pageNumber: 0)),
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        //ユーザーログインに失敗した場合
                                        if (e.code == 'user-not-found') {
                                          error = 'ユーザーは存在しません';
                                        } else if (e.code ==
                                            'invalid-email') {
                                          error = 'メールアドレスの形をしていません';
                                        } else if (e.code ==
                                            'wrong-password') {
                                          error = 'パスワードが間違っています';
                                        } else {
                                          error = 'ログインエラー';
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
                                      'ログインする',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('アカウントが未登録ですか?'),
                                    TextButton(
                                      onPressed: () async {
                                        //画面遷移
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const RegisterPage(),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                      },
                                      child: const Text('アカウントの作成'),
                                    ),
                                  ],
                                ),
                                //iOS, Androidならば
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
      ),
    );
  }
}