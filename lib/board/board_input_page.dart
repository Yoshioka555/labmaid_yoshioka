import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../network/url.dart';

class InputBoardPage extends StatefulWidget {
  const InputBoardPage({Key? key}) : super(key: key);

  @override
  State<InputBoardPage> createState() => _InputBoardPage();
}

class _InputBoardPage extends State<InputBoardPage> {

  late TextEditingController _contentController;
  final user = FirebaseAuth.instance.currentUser;

  late String firebaseUserId;
  late int userId;

  String _group = 'All';

  @override
  void initState() {
    _contentController = TextEditingController();
    firebaseUserId = user!.uid;
    _fetchMyUserData();
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future<void> _fetchMyUserData() async {
    var uriUser = Uri.parse('${httpUrl}user_id/$firebaseUserId');
    var responseUser = await http.get(uriUser);

    // レスポンスのステータスコードを確認
    if (responseUser.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseUser.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          userId = responseData['id'];
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseUser.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.98,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black45,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 15.0, top: 5.0,bottom: 5.0,right: 5.0),
              child: const Text(
                "連絡掲示板",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: "連絡事項を入力してください",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _group,
                      items: <Map<String, String>>[
                        {'display': 'All', 'value': 'All'},
                        {'display': 'Web班', 'value': 'Web班'},
                        {'display': 'Net班', 'value': 'Network班'},  // 表示は「Net班」、値は「Network班」
                        {'display': 'Grid班', 'value': 'Grid班'},
                        {'display': 'B4', 'value': 'B4'},
                        {'display': 'M1', 'value': 'M1'},
                        {'display': 'M2', 'value': 'M2'},
                        {'display': 'D', 'value': 'D'}
                      ].map<DropdownMenuItem<String>>((Map<String, String> map) {
                        return DropdownMenuItem<String>(
                          value: map['value'], // 実際の値
                          child: Text(map['display']!), // 表示する文字列
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _group = newValue!; // 実際の値を更新
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          //掲示板追加
                          await addBoard(_contentController.text, _group, userId);

                          _contentController.clear();

                          const snackBar = SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('掲示板を投稿しました。'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } catch (e) {
                          final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(e.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // 背景色
                        foregroundColor: Colors.white, // テキスト色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 角丸
                        ),
                      ),
                      child: const Text(
                        "投稿",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14, // フォントサイズ
                          fontWeight: FontWeight.bold, // 太字
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future addBoard(String content, String group, int userId) async {

    if (content =='') {
      throw '内容が入力されていません。';
    }

    final now = DateTime.now();

    final url = Uri.parse('${httpUrl}boards');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'created_at': now.toIso8601String(),
        'user_id': userId,
        'group': group,
      }),

    );

    if (response.statusCode == 200) {
      // POSTリクエストが成功した場合
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');

    } else {
      // POSTリクエストが失敗した場合
      print('Request failed with status: ${response.statusCode}');
    }

  }


}

