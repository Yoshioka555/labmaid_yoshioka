import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/user/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user/email_reset_page.dart';
import 'package:provider/provider.dart';

import '../login/login_page.dart';
import '../user/edit_user_page.dart';
import 'drawer_model.dart';

final Uri _homePageUrl = Uri.parse('https://al.kansai-u.ac.jp/');
final Uri _poleManegeUrl = Uri.parse('https://p.al.kansai-u.ac.jp/');

class UserDrawer extends StatelessWidget {
  // 定数コンストラクタ
  const UserDrawer({Key? key,}) : super(key: key);

  // build()
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrawerModel>(
      create: (_) => DrawerModel()..fetchUserList(),
      child: Drawer(
        backgroundColor: Colors.yellow,
        child: Consumer<DrawerModel>(builder: (context, model, child) {
          return ListView(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/flutter_haikei.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Menu & MyAccount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      'UserName：${model.myData?.name}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Group：${model.myData?.group}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Grade：${model.myData?.grade}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Email：${model.myData?.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '出席状況：${model.myData?.status}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15,
                    ),
                  ],
                ),
              ),
              //罫線
              const Divider(
                height: 1,
                thickness: 1,
              ),
              //サブタイトル的なもの
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '設定',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('Email 変更'),
                onTap: () async {
                  //メールアドレスとパスワード変更ページに遷移
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const EmailResetPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('アカウント情報変更'),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return EditMyPage(myData: model.myData!);
                    }),
                  );
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '外部リンク',
                ),
              ),
              //外部ページに飛ぶ時に新しいタブが生成されるようになっています
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('研究室ホームページ'),
                onTap: () => _HomelaunchUrl(),
              ),
              ListTile(
                leading: const Icon(Icons.poll),
                title: const Text('Pole Manage'),
                onTap: () => _PolelaunchUrl(),
              ),

              const Divider(
                height: 1,
                thickness: 1,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'その他',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout from Labmaid'),
                onTap: () async {
                  try {
                    showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text("ログアウトしますか？"),
                          actions: [
                            CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () async {
                                await deleteUserData();
                                await FirebaseAuth.instance.signOut();
                                await Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const LoginPage()),
                                      (route) => false,
                                );
                                const snackBar = SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('ログアウトしました'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            )
                          ],
                        ));
                  } catch (e) {
                    //失敗した場合
                    final snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(e.toString()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  //研究室ホームページ
  Future<void> _HomelaunchUrl() async {
    if (!await launchUrl(_homePageUrl)) {
      throw Exception('Could not launch $_homePageUrl');
    }
  }

//PoleManage
  Future<void> _PolelaunchUrl() async {
    if (!await launchUrl(_poleManegeUrl)) {
      throw Exception('Could not launch $_poleManegeUrl');
    }
  }

}


