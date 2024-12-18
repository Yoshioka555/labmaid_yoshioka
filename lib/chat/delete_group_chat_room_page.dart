import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:labmaidfastapi/header_footer_drawer/footer.dart';

import '../domain/chat_data.dart';
import 'package:http/http.dart' as http;

import '../network/url.dart';

class GroupChatRoomDeletePage extends StatefulWidget {
  final List<GroupChatRoomData> groupChatRoomList;
  const GroupChatRoomDeletePage({Key? key, required this.groupChatRoomList}) : super(key: key);

  @override
  State<GroupChatRoomDeletePage> createState() => _GroupChatRoomDeletePage();
}

class _GroupChatRoomDeletePage extends State<GroupChatRoomDeletePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          'ルーム削除',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: widget.groupChatRoomList.isNotEmpty
          ? Scrollbar(
        child: ListView.builder(
          itemCount: widget.groupChatRoomList.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return GestureDetector(
              onTap: () async {
                //グループチャットルームを削除する
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('グループを削除する'),
                      content: const Text(
                        'このグループを削除しますか？',
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
                            _removeGroup(widget.groupChatRoomList[index].id);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) {
                                    return const Footer(pageNumber: 2);
                                  }
                              ),
                            );
                          },
                          child: const Text('削除する'),
                        ),
                      ],
                    );
                  },
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
                    backgroundImage: widget.groupChatRoomList[index].imgData != '' ? Image.memory(
                      base64Decode(widget.groupChatRoomList[index].imgData),
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
                  title: Text(widget.groupChatRoomList[index].name),
                  trailing: const Icon(Icons.delete),
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
    );
  }

  void _removeGroup(int groupChatRoomId) async {
    var uri = Uri.parse('${httpUrl}delete_group_chat_room/$groupChatRoomId');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('グループを削除しました。')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('グループの削除に失敗しました。')),
      );
    }
  }
}


