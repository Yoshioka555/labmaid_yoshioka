import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//import 'package:labmaidfastapi/board/board_index_page.dart';
//import 'package:labmaidfastapi/board/board_input_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../../domain/user_data.dart';
import '../../network/url.dart';

//変更点
//そのままコピペしてください
//mobile版アテンダンスページの出席状況表示ページ

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementPage> createState() => _AttendanceManagementPage();
}

class _AttendanceManagementPage extends State<AttendanceManagementPage> {
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;
  final user = FirebaseAuth.instance.currentUser;

  List<UserAttendanceData> users = [];

  late String firebaseUserId;
  late int userId;

  @override
  void initState() {
    firebaseUserId = user!.uid;
    _fetchAttendanceUserList();
    _fetchMyUserData();
    _connectWebSocket();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  //ダミーデータ
  /*
  void _loadDummyData() {
    setState(() {
      users = [
        UserAttendanceData(
          id: 1,
          group: 'Web班',
          name: '山田',
          status: '出席',
        ),
        UserAttendanceData(
          id: 2,
          group: 'Web班',
          name: '高橋',
          status: '授業中',
        ),
        UserAttendanceData(
          id: 3,
          group: 'Web班',
          name: '加藤',
          status: '未定',
        ),
        UserAttendanceData(
          id: 4,
          group: 'Web班',
          name: '林',
          status: '一時退席',
        ),

        // Grid班
        UserAttendanceData(
          id: 5,
          group: 'Grid班',
          name: '佐藤',
          status: '欠席',
        ),
        UserAttendanceData(
          id: 6,
          group: 'Grid班',
          name: '中村',
          status: '出席',
        ),
        UserAttendanceData(
          id: 7,
          group: 'Grid班',
          name: '伊藤',
          status: '未定',
        ),

        // Net班
        UserAttendanceData(
          id: 8,
          group: 'Net班',
          name: '鈴木',
          status: '出席',
        ),
        UserAttendanceData(
          id: 9,
          group: 'Net班',
          name: '小林',
          status: '授業中',
        ),
        UserAttendanceData(
          id: 10,
          group: 'Net班',
          name: '松本',
          status: '欠席',
        ),
        UserAttendanceData(
          id: 11,
          group: 'Net班',
          name: '田中',
          status: '一時退席',
        ),
        UserAttendanceData(
          id: 12,
          group: 'Net班',
          name: '藤本',
          status: '出席',
        ),

        // 教員
        UserAttendanceData(
          id: 13,
          group: '教員',
          name: '木村',
          status: '授業中',
        ),
      ];
    });
  }
  */

  Future<void> _fetchAttendanceUserList() async {
    //ダミーデータの参照用
    //_loadDummyData();

    var uri = Uri.parse('${httpUrl}users_attendance');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          users = body
              .map((dynamic json) => UserAttendanceData.fromJson(json))
              .toList();
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
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

  Future attendanceUpdate(String updateStatus) async {
    var uri = Uri.parse('${httpUrl}update_user_status/$userId');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'status': updateStatus,
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

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_user_status'),
    );
    _channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      final int id = data['user_id'];
      final String status = data['status'];
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == id) {
          setState(() {
            users[i].status = status;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('出席');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  "出席しました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green[400],
                            ),
                            child: const FittedBox(
                              child: Text(
                                '出席',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('一時退席');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.yellow,
                                content: Text(
                                  "一時退席しました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              //model.fetchAttendanceList();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.yellow,
                            ),
                            child: const FittedBox(
                              child: Text(
                                '一時退席',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('帰宅');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.grey,
                                content: Text(
                                  "帰宅しました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              //model.fetchAttendanceList();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                            ),
                            child: const FittedBox(
                              child: Text(
                                '帰宅',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('欠席');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "欠席しました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              //model.fetchAttendanceList();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: const FittedBox(
                              child: Text(
                                '欠席',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('未出席');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.blue,
                                content: Text(
                                  "未出席になりました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              //model.fetchAttendanceList();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            child: const FittedBox(
                              child: Text(
                                '未出席',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await attendanceUpdate('授業中');
                              const snackBar = SnackBar(
                                backgroundColor: Colors.purple,
                                content: Text(
                                  "授業中になりました",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                              //model.fetchAttendanceList();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.purple,
                            ),
                            child: const FittedBox(
                              child: Text(
                                '授業中',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Row(children: [
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black45,
                          ),
                        ),
                        child: const Text('Net班'), //グループ名
                      ),
                      Expanded(
                        child: Row(
                          children: groupAttendanceUser(users, 'Network班'),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Row(children: [
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black45,
                          ),
                        ),
                        child: const Text('Grid班'), //グループ名
                      ),
                      Expanded(
                        child: Row(
                          children: groupAttendanceUser(users, 'Grid班'),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Row(children: [
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black45,
                          ),
                        ),
                        child: const Text('Web班'), //グループ名
                      ),
                      Expanded(
                        child: Row(
                          children: groupAttendanceUser(users, 'Web班'),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Row(children: [
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black45,
                          ),
                        ),
                        child: const Text('教員'), //グループ名
                      ),
                      Expanded(
                        child: Row(
                          children: groupAttendanceUser(users, '教員'),
                        ),
                      ),
                    ]),
                  ),
                ),
                //const InputBoardPage(),
              ],
            ),
          ),
          /*const SliverToBoxAdapter(
            child: IndexBoardPage()
          ),

           */
        ],
      ),
    );
  }

  List<Widget> groupAttendanceUser(
      List<UserAttendanceData> users, String group) {
    List<Widget> index = users
        .where((user) => user.group.contains(group)) // フィルタリング
        .map(
          (user) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _attendanceColor(user.status),
                  border: Border.all(
                    color: Colors.black45,
                  ),
                ),
                child: FittedBox(child: Text(user.name)),
              ),
            ),
          ),
        )
        .toList();
    return index;
  }

  //以下でColorsに.withOpacity(0.7)を追加して透過させている
  Color _attendanceColor(String text) {
    if (text == '一時退席') {
      return Colors.yellow.withOpacity(0.7);
    } else if (text == '出席') {
      return Colors.green.withOpacity(0.7);
    } else if (text == '欠席') {
      return Colors.red.withOpacity(0.7);
    } else if (text == '帰宅') {
      return Colors.grey.withOpacity(0.7);
    } else if (text == '授業中') {
      return Colors.purple.withOpacity(0.7);
    } else {
      return Colors.blue.withOpacity(0.7);
    }
  }
}
