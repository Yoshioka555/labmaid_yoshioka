import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../login/login_page.dart';
import 'email_reset_model.dart';

class EmailResetPage extends StatefulWidget {
  const EmailResetPage({super.key});
  @override
  _EmailResetPageState createState() => _EmailResetPageState();
}

class _EmailResetPageState extends State<EmailResetPage> {

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmailResetModel>(
      create: (_) => EmailResetModel()..fetchEmailReset(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightGreen.shade700,
          title: const Text('Email変更',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white,
          ),
        ),
        body: Consumer<EmailResetModel>(builder: (context, model, child) {

          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus(); // フォーカスを解除
                    },
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.email, // メールアドレスを示すアイコン
                                  color: Colors.grey[600],
                                  size: 24.0, // アイコンのサイズを設定
                                ),
                                const SizedBox(width: 15), // アイコンとテキストの間にスペースを追加
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '現在のメールアドレス',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        model.initialEmail,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextField(
                              controller: model.emailController,
                              decoration: const InputDecoration(
                                  labelText: 'NewEmail　　※必要',
                                  icon: Icon(Icons.email),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextFormField(
                              controller: model.passwordController,
                              obscureText: _isObscure,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  icon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),

                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  )
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: SizedBox(
                            //横長がウィンドウサイズの３割になる設定
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                model.startLoading();
                                try {
                                  await model.updateUserEmail();

                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginPage()),
                                        (route) => false,
                                  );
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('メールアドレスの変更確認のメールを新しいメールアドレスに送信しました。確認してください。'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } catch (error) {
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(error.toString()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } finally {
                                  model.endLoading();
                                }
                              },
                              child: const Text('変更する'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

}