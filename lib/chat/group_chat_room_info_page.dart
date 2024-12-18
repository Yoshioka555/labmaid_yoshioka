import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/add_group_chat_member.dart';
import 'package:labmaidfastapi/header_footer_drawer/footer.dart';
import '../domain/chat_data.dart';
import '../domain/user_data.dart';

import 'package:http/http.dart' as http;

import '../network/url.dart';

class GroupChatRoomInfo extends StatefulWidget {
  final GroupChatRoomData groupChatRoomData;
  final List<GroupChatUserData> groupChatUsers;
  final UserData myData;
  const GroupChatRoomInfo({Key? key,  required this.groupChatRoomData, required this.groupChatUsers, required this.myData}) : super(key: key);

  @override
  State<GroupChatRoomInfo> createState() => _GroupChatRoomInfoState();
}

class _GroupChatRoomInfoState extends State<GroupChatRoomInfo> {
  List<GroupChatMember> groupChatNotUsers = [];

  Future getGroupChatNotUsers(int groupChatRoomId) async {
    var uri = Uri.parse('${httpUrl}get_users_not_in_group/$groupChatRoomId');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);
      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      groupChatNotUsers = body.map((dynamic json) => GroupChatMember.fromJson(json)).toList();

    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          'ルーム詳細情報',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //add chat member
              await getGroupChatNotUsers(widget.groupChatRoomData.id);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMemberAddPage(
                      groupChatRoomData: widget.groupChatRoomData,
                      groupChatNotUsers: groupChatNotUsers,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.group_add),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.deepOrange.withOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 30,
                        backgroundImage: widget.groupChatRoomData.imgData != '' ? Image.memory(
                          base64Decode(widget.groupChatRoomData.imgData),
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
                      const SizedBox(width: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ルーム名： ${widget.groupChatRoomData.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                memberList(widget.groupChatUsers, widget.myData, widget.groupChatRoomData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget memberList(List<GroupChatUserData> groupChatUsers, UserData myData, GroupChatRoomData groupChatRoomData) {
    if(groupChatUsers.isNotEmpty){
      return Column(
        children: [
          const Center(
            child: Text('メンバーリスト',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          ListView.builder(
            itemCount: groupChatUsers.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return groupChatUsers[index].join == true ?
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: groupChatUsers[index].imgData != '' ? Image.memory(
                        base64Decode(groupChatUsers[index].imgData),
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
                    title: Text(groupChatUsers[index].name),
                    subtitle: Text('${groupChatUsers[index].grade} ${groupChatUsers[index].group}'),
                  trailing: groupChatUsers[index].id != myData.id ? 
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('メンバーを退会させる'),
                              content: Text(
                                '${groupChatUsers[index].name} をこのグループから退会させますか？',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('キャンセル'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _removeMemberFromGroup(groupChatUsers[index], groupChatRoomData);
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const Footer(pageNumber: 2),
                                      ),
                                    );
                                  },
                                  child: const Text('退会させる'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                      : IconButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('グループを退会する'),
                            content: const Text(
                              'あなたはこのグループを退会しますか？',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  _exitMeFromGroup(myData, groupChatRoomData);
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const Footer(pageNumber: 2),
                                    ),
                                  );
                                },
                                child: const Text('退会する'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                      icon: const Icon(Icons.exit_to_app, color: Colors.red,),
                  ),
                ),
              )
              : const SizedBox();
            },
          ),
        ],
      );
    }
    else {
      return const Text('チャットメンバーはいません');
    }
  }

  void _removeMemberFromGroup(GroupChatUserData user, GroupChatRoomData groupChatRoomData) async {
    // サーバーやデータベースとの通信を行い、ユーザーをグループから削除
    var uri = Uri.parse('${httpUrl}group_member_update/${groupChatRoomData.id}/${user.id}');

    final response = await http.patch(uri);

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} がグループから退会させました。')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メンバーの退会に失敗しました。')),
      );
    }
  }

  void _exitMeFromGroup(UserData myData, GroupChatRoomData groupChatRoomData) async {
    // サーバーやデータベースとの通信を行い、ユーザーをグループから削除
    var uri = Uri.parse('${httpUrl}group_member_update/${groupChatRoomData.id}/${myData.id}');

    final response = await http.patch(uri);

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('あなた(${myData.name})がグループから退会されました。')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退会に失敗しました。')),
      );
    }
  }


}