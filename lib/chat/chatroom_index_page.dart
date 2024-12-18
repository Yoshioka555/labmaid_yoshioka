import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/delete_group_chat_room_page.dart';
import 'package:labmaidfastapi/chat/group_chat_page.dart';
import 'package:labmaidfastapi/chat/private_chat_page.dart';
import '../domain/chat_data.dart';
import '../domain/user_data.dart';
import '../door_status/door_status_appbar.dart';
import '../header_footer_drawer/drawer.dart';
import '../network/url.dart';
import 'create_group_chat_room_page.dart';
import 'package:http/http.dart' as http;

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPage();
}

class _ChatRoomListPage extends State<ChatRoomListPage> {
  List<GroupChatRoomData> groupChatRoomList = [];
  List<UserData> userData = [];
  List<GroupChatUserData> groupChatUsers = [];
  List<GroupChatRoomData> groupChatData = [];
  List<GroupChatRoomData> notGroupChatData = [];
  late int privateChatroomId;
  late UserData myData;

  @override
  void initState() {
    fetchChatRoomList();
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future<void> getGroupChatRoomList() async {
    var uri = Uri.parse('${httpUrl}get_group_chat_rooms');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      groupChatRoomList = body.map((dynamic json) => GroupChatRoomData.fromJson(json)).toList();

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<void> fetchChatRoomList() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // MyUser情報を取得
    var uri = Uri.parse('${httpUrl}users/${currentUser!.uid}');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          myData = UserData.fromJson(responseData);
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }

    // 個人チャットのユーザを取得する
    var url = Uri.parse('${httpUrl}chat_users/${currentUser.uid}');

    // GETリクエストを送信
    var responseGet = await http.get(url);

    // レスポンスのステータスコードを確認
    if (responseGet.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseGet.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          userData = body.map((dynamic json) => UserData.fromJson(json)).toList();
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseGet.statusCode}');
    }

    // 参加中のグループチャットの一覧を取得
    var uriEntryGroup = Uri.parse('${httpUrl}get_entry_group_chat_room/${myData.id}');
    // GETリクエストを送信
    var responseEntryGroup = await http.get(uriEntryGroup);

    // レスポンスのステータスコードを確認
    if (responseEntryGroup.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseEntryGroup.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      //　必要なデータを取得
      if (mounted) {
        setState(() {
          groupChatData = body.map((dynamic json) => GroupChatRoomData.fromJson(json)).toList();
        });
      }

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseEntryGroup.statusCode}');
    }

    // 参加していないグループチャット一覧を取得する
    var uriNotEntryGroup = Uri.parse('${httpUrl}get_not_entry_group_chat_room/${myData.id}');
    // GETリクエストを送信
    var responseNotEntryGroup = await http.get(uriNotEntryGroup);

    // レスポンスのステータスコードを確認
    if (responseNotEntryGroup.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseNotEntryGroup.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          notGroupChatData = body.map((dynamic json) => GroupChatRoomData.fromJson(json)).toList();
        });
      }

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseNotEntryGroup.statusCode}');
    }

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    //グループチャット削除ページへ遷移
                    await getGroupChatRoomList();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) {
                            return GroupChatRoomDeletePage(groupChatRoomList: groupChatRoomList);
                          }
                      ),
                    );
                  }
              ),
            ),
          ],
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: false,
          elevation: 0.0,
          title: const DoorStatusAppbar(),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: '個人',),
              Tab(text: '参加中',),
              Tab(text: '未参加',),
            ],
          ),
        ),
        drawer: const UserDrawer(),
        body: TabBarView(
          children: [
            userData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: userData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //個人チャットルーム遷移
                      await createOrGetPrivateChatRoom(userData[index].id);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) {
                              return PrivateChatPage(privateChatroomId: privateChatroomId, userData: userData[index], myData: myData);
                            }
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: userData[index].imgData != '' ? Image.memory(
                            base64Decode(userData[index].imgData),
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/default.png'),
                        ),
                        title: Text(userData[index].name),
                        subtitle: Text('${userData[index].group}　${userData[index].grade}　${userData[index].status}'),
                        trailing: const Icon(Icons.input),
                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            groupChatData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: groupChatData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //グループチャットルーム遷移
                      await getGroupChatUsers(groupChatData[index].id);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) {
                              return GroupChatPage(groupChatRoomData: groupChatData[index], myData: myData, groupUsers: groupChatUsers);
                            }
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: groupChatData[index].imgData != '' ? Image.memory(
                            base64Decode(groupChatData[index].imgData),
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/group_default.jpg'),
                        ),
                        title: Text(groupChatData[index].name),
                        trailing: const Icon(Icons.input),
                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
            notGroupChatData.isNotEmpty ? Scrollbar(
              child: ListView.builder(
                itemCount: notGroupChatData.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      //グループチャットルーム遷移

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50,
                          backgroundImage: notGroupChatData[index].imgData != '' ? Image.memory(
                            base64Decode(notGroupChatData[index].imgData),
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                              );
                            },
                          ).image
                              : const AssetImage('assets/images/group_default.jpg'),
                        ),
                        title: Text(notGroupChatData[index].name),

                      ),
                    ),
                  );
                },
              ),
            )
            : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            //ルーム追加
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) {
                    return const AddRoomPage();
                  }),
            );
          },
        ),
      ),
    );
  }

  Future createOrGetPrivateChatRoom(int userId) async {
    var uri = Uri.parse('${httpUrl}private_chat_room/${myData.id}/$userId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      privateChatroomId = responseData['id'];

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future getGroupChatUsers(int groupChatRoomId) async {
    var uri = Uri.parse('${httpUrl}group_chat_room_users/$groupChatRoomId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      groupChatUsers = body.map((dynamic json) => GroupChatUserData.fromJson(json)).toList();

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

}


