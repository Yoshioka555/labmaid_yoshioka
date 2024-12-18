import 'dart:convert';
import 'package:flutter/material.dart';
import '../domain/chat_data.dart';
import '../domain/user_data.dart';
import 'package:http/http.dart' as http;

import '../header_footer_drawer/footer.dart';
import '../network/url.dart';

class ChatMemberAddPage extends StatefulWidget {
  final GroupChatRoomData groupChatRoomData;
  final List<GroupChatMember> groupChatNotUsers;
  const ChatMemberAddPage({Key? key, required this.groupChatRoomData, required this.groupChatNotUsers}) : super(key: key);

  @override
  State<ChatMemberAddPage> createState() => _ChatMemberAddPage();

}

class _ChatMemberAddPage extends State<ChatMemberAddPage> {
  List<int> newMember = [];

  void itemChange(bool val, int index, List<GroupChatMember> memberList) {
    memberList[index].join = val;
  }

  Future addMember(List<GroupChatMember> newGroupChatMembers, GroupChatRoomData groupChatRoomData) async {

    //　メンバーの追加
    for (int i=0; i<newGroupChatMembers.length; i++) {
      if (newGroupChatMembers[i].join == true) {
        newMember.add(newGroupChatMembers[i].id);
      }
    }

    if (newMember.isEmpty) {
      throw '追加するメンバーがいません。';
    }

    final url = Uri.parse('${httpUrl}add_members/${groupChatRoomData.id}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'member_ids': newMember,
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
          'メンバー追加',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await addMember(widget.groupChatNotUsers, widget.groupChatRoomData);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Footer(pageNumber: 2),
                    ),
                  );

                  const snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('新しいメンバーを追加しました'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  //失敗した場合

                  final snackBar = SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(e.toString()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } finally {
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text("追加"),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: widget.groupChatNotUsers.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  backgroundImage: widget.groupChatNotUsers[index].imgData != ''
                      ? Image.memory(
                    base64Decode(widget.groupChatNotUsers[index].imgData),
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ).image
                      : const AssetImage('assets/images/default.png'),
                ),
                title: Text(widget.groupChatNotUsers[index].name),
                subtitle: Text(widget.groupChatNotUsers[index].group),
                trailing: Checkbox(
                  value: widget.groupChatNotUsers[index].join,
                  onChanged: (bool? val) {
                    setState(() {
                      itemChange(val!, index, widget.groupChatNotUsers);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}