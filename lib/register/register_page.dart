import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../pick_export/pick_image_export.dart';

import '../header_footer_drawer/footer.dart';
import 'register_model.dart';
import 'dart:typed_data';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPassObscure = true;
  bool _isObscure = true;

  String _group = '';

  //エラーを表示
  String? error;
  String _grade = 'B4';
  String _gradeDisplay = 'B4';

  Uint8List? imageData;

  void _handleRadioButton(String group) => setState(() {
    _group = group;
  });

  void _handleDropdownButton(String grade) => setState(() {
    _grade = grade;
    _gradeDisplay = grade;
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterModel>(
      create: (_) => RegisterModel(),
      child: Theme(
        data: ThemeData(
          useMaterial3: true, // Material 3 を有効化
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
        ),
        child: Scaffold(
          //appBar: AppBar(title: const Text('新規登録')),
          body: Consumer<RegisterModel>(builder: (context, model, child) {
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
                height: 800,
                width: 400,
                child: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
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
                      //スクロール機能
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                            children: [
                              const Text(
                                'アカウント作成',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                decoration:
                                const BoxDecoration(color: Colors.white),
                                child: GestureDetector(
                                  onTap: () async {
                                    //getImageFromGallery();
                                    final _imageData =
                                    await PickImage().pickImage();
                                    setState(() {
                                      imageData = _imageData;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 50,
                                    backgroundImage: imageData != null
                                        ? Image.memory(imageData!).image
                                        : const AssetImage(
                                        'assets/images/default.png'),
                                  ),
                                ),
                              ),
                              TextField(
                                controller: model.emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  //メールのアイコン
                                  icon: Icon(Icons.mail),
                                ),
                                onChanged: (text) {
                                  model.setEmail(text);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: model.passwordController,
                                obscureText: _isPassObscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  //鍵のアイコン
                                  icon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPassObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isPassObscure = !_isPassObscure;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (text) {
                                  model.setPassword(text);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: model.passwordConfirmController,
                                obscureText: _isObscure,
                                decoration: InputDecoration(
                                    labelText: 'Password Confirmation',
                                    //鍵のアイコン
                                    icon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                    )),
                                onChanged: (text) {
                                  model.setPassConfirm(text);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: model.nameController,
                                decoration: const InputDecoration(
                                  labelText: '名前 (苗字のみ)',
                                  icon: Icon(Icons.person),
                                ),
                                onChanged: (text) {
                                  model.setName(text);
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '選択した班：$_group',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                            value: 'Web班',
                                            groupValue: _group,
                                            onChanged: (text) {
                                              _handleRadioButton(text!);
                                              model.groupController.text =
                                                  _group;
                                              model.setGroup(_group);
                                            },
                                          ),
                                          const Text('Web班'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                            value: 'Grid班',
                                            groupValue: _group,
                                            onChanged: (text) {
                                              _handleRadioButton(text!);
                                              model.groupController.text =
                                                  _group;
                                              model.setGroup(_group);
                                            },
                                          ),
                                          const Text('Grid班'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                            value: 'Network班',
                                            groupValue: _group,
                                            onChanged: (text) {
                                              _handleRadioButton(text!);
                                              model.groupController.text =
                                                  _group;
                                              model.setGroup(_group);
                                            },
                                          ),
                                          const Text('Network班'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                            value: '教員',
                                            groupValue: _group,
                                            onChanged: (text) {
                                              _handleRadioButton(text!);
                                              model.groupController.text =
                                                  _group;
                                              model.setGroup(_group);
                                            },
                                          ),
                                          const Text('教員'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '選択した学年：$_grade',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              DropdownButton(
                                  value: _gradeDisplay,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'B4',
                                      child: Text('B4'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'M1',
                                      child: Text('M1'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'M2',
                                      child: Text('M2'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'D1',
                                      child: Text('D1'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'D2',
                                      child: Text('D2'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'D3',
                                      child: Text('D3'),
                                    ),
                                    DropdownMenuItem(
                                      value: '教授',
                                      child: Text('教授'),
                                    ),
                                  ],
                                  onChanged: (text) {
                                    _handleDropdownButton(text!);
                                    model.gradeController.text = _grade;
                                    model.setGrade(_grade);
                                  }),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(200, double.infinity),
                                    backgroundColor: Colors.black, //ボタンの背景色
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  onPressed: () async {
                                    model.startLoading();
                                    try {
                                      await model.signUp(imageData);
                                      //ユーザー登録
                                      //スタック内のすべての画面を削除し、新しい画面に遷移できる
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const Footer(pageNumber: 0)),
                                            (route) => false,
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      //ユーザー登録に失敗した場合
                                      if (e.code == 'weak-password') {
                                        error = 'パスワードが弱いです。６文字以上を入力してください。';
                                      } else if (e.code ==
                                          'email-already-in-use') {
                                        error = 'すでに利用されているメールアドレス';
                                      } else if (e.code == 'invalid-email') {
                                        error = 'メールアドレスの形をしていません。';
                                      } else {
                                        error = 'アカウント作成エラー';
                                      }
                                      final snackBar = SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(error.toString()),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } catch (e) {
                                      final snackBar = SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(e.toString()),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } finally {
                                      model.endLoading();
                                    }
                                  },
                                  child: const Text(
                                    '登録する',
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