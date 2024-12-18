import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/board_data.dart';
import '../network/url.dart';

class IndexBoardPage extends StatefulWidget {
  const IndexBoardPage({Key? key}) : super(key: key);

  @override
  State<IndexBoardPage> createState() => _IndexBoardPage();
}

class _IndexBoardPage extends State<IndexBoardPage> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1; // 現在のページ番号
  bool _isLoading = false; // データを読み込んでいるか
  bool _hasMore = true; // もっとデータがあるかどうか

  final user = FirebaseAuth.instance.currentUser;

  late String firebaseUserId;
  int? userId;

  late WebSocketChannel _channel;

  List<BoardData> boards = [];

  List<AcknowledgementData> acknowledgementUsers = [];

  final TextEditingController _formController = TextEditingController();

  void toggleForm(String initialText) {
    setState(() {
      _formController.text = initialText;
    });
  }

  void resetCommentDisplay(int id) {
    setState(() {
      for (int i = 0; i < boards.length; i++) {
        if (boards[i].id != id) {
          boards[i].commentDisplay = false;
        }
      }
    });
  }

  void resetIsAcknowledgement(int boardId) {
    setState(() {
      for (int i = 0; i < boards.length; i++) {
        if (boards[i].id == boardId) {
          boards[i].isAcknowledged = ! boards[i].isAcknowledged;
        }
      }
    });
  }

  void commentDisplayBool(int id, bool display) {
    setState(() {
      for (int i = 0; i < boards.length; i++) {
        if (boards[i].id == id) {
          boards[i].commentDisplay = display;
        }
      }
    });
  }

  @override
  void initState() {
    firebaseUserId = user!.uid;
    _fetchMyUserData();
    _connectWebSocket();
    _connectWebSocketAcknowledgement();
    // スクロール位置のリスナーを設定
    _scrollController.addListener(() {
      // スクロール位置が一番下に達したら次のページを取得
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMore) {
          _fetchBoard();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _fetchBoard() async {
    setState(() {
      _isLoading = true;
    });

    var uri = Uri.parse('${httpUrl}boards/$userId/?page=$_page');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      if (mounted) {
        setState(() {
          // 新しいデータを追加
          boards.addAll(body.map((dynamic json) => BoardData.fromJson(json)).toList());
          _page++;
        });
      }

      // データが空でない限り、次のページがあるとみなす
      setState(() {
        _isLoading = false;
        _hasMore = body.isNotEmpty; // 次のページが存在するか
      });
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
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

    _fetchBoard();
  }

  Future<void> _fetchAcknowledge(int boardId) async {


    var uri = Uri.parse('${httpUrl}acknowledgement_users/$boardId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      if (mounted) {
        setState(() {
          // 新しいデータを追加
          acknowledgementUsers.clear();
          acknowledgementUsers.addAll(body.map((dynamic json) => AcknowledgementData.fromJson(json)).toList());

        });
      }


    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_board_list'),
    );
    _channel.stream.listen((message) {

      // JSONデータをデコード
      var messageData = jsonDecode(message);
      if (messageData['action'] == 'create') {
        final board = BoardData.fromJson(messageData);
        setState(() {
          boards.insert(0, board);
        });
      } else if (messageData['action'] == 'delete') {
        setState(() {
          boards.removeWhere((board) => board.id == messageData['id']);
        });
      }
    });
  }

  void _connectWebSocketAcknowledgement() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_acknowledgement_list'),
    );
    _channel.stream.listen((message) {

      // JSONデータをデコード
      var messageData = jsonDecode(message);
      if (messageData['action'] == 'create') {
        setState(() {
          for (int i = 0; i < boards.length; i++) {
            if (boards[i].id == messageData['board_id']) {
              boards[i].acknowledgements++;
            }
          }
        });
      } else if (messageData['action'] == 'delete') {
        setState(() {
          for (int i = 0; i < boards.length; i++) {
            if (boards[i].id == messageData['board_id']) {
              boards[i].acknowledgements--;
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return userId == null ? const Center(child: CircularProgressIndicator())
        : SelectionArea(
          child: SizedBox(
                height: MediaQuery.of(context).size.height // 画面全体の高さ
            - AppBar().preferredSize.height // AppBar の高さ
            - MediaQuery.of(context).padding.top // ステータスバーの高さ
            - kBottomNavigationBarHeight, // ボトムナビゲーションバーの高さ（必要に応じて）
                width: MediaQuery.of(context).size.width * 0.98,
                child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
          padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 1.0,bottom: 1.0),
          child: Scrollbar(
            controller: _scrollController,
            child: (_isLoading && boards.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: boards.length + 1, // ローディング表示分+1
              itemBuilder: (context, index) {
                if (index == boards.length) {
                  // ローディング表示
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }
                final board = boards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Colors.black, // 枠線の色
                        width: 1.0,         // 枠線の太さ
                      ),
                    ),
                    color:  userId == board.userId ? Colors.amber : _groupColor(board.group),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${board.userName} To ${_groupName(board.group)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                  overflow: TextOverflow.visible, // はみ出す場合は改行
                                  softWrap: true, // 自動で改行を許可
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  DateFormat('yyyy年MM月dd日 HH:mm').format(board.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.visible, // はみ出す場合は改行
                                  softWrap: true, // 自動で改行を許可
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            board.content,
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 5.0),
                          board.userId == userId
                              ? _buttonDelete(board.id, board.acknowledgements)
                              : _buttonRow(board.group, board.id, userId!, board.isAcknowledged, board.acknowledgements),
                          //　コメント入力欄
                          if (boards[index].commentDisplay)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _formController,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      filled: true, // 背景を塗りつぶす
                                      fillColor: Colors.white, // 背景色を白に設定
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // 枠線の色を黒に設定
                                          width: 1.0, // 枠線の太さを設定
                                        ),
                                      ),
                                      labelText: '返信を入力',
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FilledButton(
                                        onPressed: () async {
                                          // フォームの内容を送信
                                          try {
                                            //掲示板追加
                                            await addComment(_formController.text, board.group, userId!);

                                            const snackBar = SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text('掲示板を投稿しました。'),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                            commentDisplayBool(board.id, false);
                                            toggleForm('');
                                          } catch (e) {
                                            final snackBar = SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(e.toString()),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }

                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.teal, // 背景色: 黄緑色
                                          foregroundColor: Colors.white, // 文字色: 白
                                        ),
                                        child: const Text(
                                          '送信',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          commentDisplayBool(board.id, false);
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.white, // 背景色: 白
                                          foregroundColor: Colors.black, // 文字色: 黒
                                          side: const BorderSide(       // 枠線の設定
                                            color: Colors.black, // 枠線の色: 黒
                                            width: 1.0,         // 枠線の太さ
                                          ),
                                        ),
                                        child: const Text(
                                          '閉じる',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
                ),
              ),
        );
  }

  Widget _buttonDelete (int id, int acknowledgements) {
    return Wrap(
      spacing: 8.0, // ボタン間の横方向の余白
      runSpacing: 4.0, // ボタン間の縦方向の余白
      children: [
        ElevatedButton(
          onPressed: () async {
            try {
              await deleteBoard(id);
              const snackBar = SnackBar(
                backgroundColor: Colors.green,
                content: Text('掲示板を削除しました。'),
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
            backgroundColor: Colors.red, // 背景色
            foregroundColor: Colors.white, // テキスト色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // 角丸
            ),
          ),
          child: const Text(
            "削除",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // フォントサイズ
              fontWeight: FontWeight.bold, // 太字
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min, // アイコンとテキストが詰まるようにする
            children: [
              GestureDetector(

                onLongPress: () async {
                  // 長押しでモーダル表示
                  await _fetchAcknowledge(id);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '了解したユーザー',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (acknowledgementUsers.isEmpty)
                              const Text('まだ了解したユーザーはいません'),
                            if (acknowledgementUsers.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: acknowledgementUsers.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(acknowledgementUsers[index].userName),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      color: Colors.grey, // いいね状態で色を変更
                    ),
                    const SizedBox(width: 4.0),
                    Text('$acknowledgements'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buttonRow (String group, int id, int userId, bool isAcknowledged, int acknowledgements) {
    return Column(
      children: [
        Wrap(
          spacing: 8.0, // ボタン間の横方向の余白
          runSpacing: 4.0, // ボタン間の縦方向の余白
          children: [
            // 返信ボタン
            FilledButton(
              onPressed: () {
                toggleForm('');
                resetCommentDisplay(id);
                commentDisplayBool(id, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal, // 背景色: 黄緑色
                foregroundColor: Colors.white, // 文字色: 白
              ),
              child: Text(
                '${_groupName(group)}へ返信',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            // 今から行くボタン
            FilledButton(
              onPressed: () {
                toggleForm('今から行きます');
                resetCommentDisplay(id);
                commentDisplayBool(id,true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white, // 背景色: 白
                foregroundColor: Colors.black, // 文字色: 黒
                side: const BorderSide(       // 枠線の設定
                  color: Colors.black, // 枠線の色: 黒
                  width: 1.0,         // 枠線の太さ
                ),
              ),
              child: const Text(
                '今行く',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            // 研究室ボタン
            FilledButton(
              onPressed: () {
                toggleForm('研究室にいます');
                resetCommentDisplay(id);
                commentDisplayBool(id,true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white, // 背景色: 白
                foregroundColor: Colors.black, // 文字色: 黒
                side: const BorderSide(       // 枠線の設定
                  color: Colors.black, // 枠線の色: 黒
                  width: 1.0,         // 枠線の太さ
                ),
              ),
              child: const Text(
                '研究室',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        // 了解アイコン
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min, // アイコンとテキストが詰まるようにする
            children: [
              GestureDetector(
                onTap: () async {
                  resetIsAcknowledgement(id);
                  if (isAcknowledged == false) {
                    await addAcknowledgement(userId, id);
                  } else {
                    await deleteAcknowledgement(userId, id);
                  }
                },
                onLongPress: () async {
                  // 長押しでモーダル表示
                  await _fetchAcknowledge(id);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '了解したユーザー',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (acknowledgementUsers.isEmpty)
                              const Text('まだ了解したユーザーはいません'),
                            if (acknowledgementUsers.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: acknowledgementUsers.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(acknowledgementUsers[index].userName),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: isAcknowledged ? Colors.blue : Colors.grey, // いいね状態で色を変更
                    ),
                    const SizedBox(width: 4.0),
                    Text('$acknowledgements'),
                  ],
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }

  String _groupName(String group) {
    if (group == 'Network班') {
      return 'Net班';
    } else {
      return group;
    }
  }

  Color _groupColor(String group) {
    if (group == 'All') {
      return Colors.red.shade300;
    } else if (group == 'Web班') {
      return Colors.cyan;
    } else if (group == 'Network班') {
      return Colors.yellow;
    } else if (group == 'Grid班') {
      return Colors.lightGreen;
    } else {
      return Colors.white;
    }
  }

  Future addComment(String content, String group, int userId) async {

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

  Future addAcknowledgement(int userId, int boardId) async {

    final now = DateTime.now();

    final url = Uri.parse('${httpUrl}acknowledgements');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'board_id': boardId,
        'created_at': now.toIso8601String(),
        'user_id': userId,
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

  Future deleteBoard(int id) async {
    var uri = Uri.parse('${httpUrl}boards/$id');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      // 成功時の処理
      print('Board deleted successfully');
    } else {
      // エラー時の処理
      print('Failed to delete the attendance');
    }
  }

  Future deleteAcknowledgement(int userId, int boardId) async {
    var uri = Uri.parse('${httpUrl}acknowledgements/$boardId/$userId');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      // 成功時の処理
      print('Acknowledgement deleted successfully');
    } else {
      // エラー時の処理
      print('Failed to delete the attendance');
    }
  }

}

