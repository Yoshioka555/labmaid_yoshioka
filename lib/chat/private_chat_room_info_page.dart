import 'dart:convert';

import 'package:flutter/material.dart';
import '../domain/user_data.dart';

class PrivateChatRoomInfo extends StatefulWidget {
  final int privateChatroomId;
  final UserData userData;
  final UserData myData;
  const PrivateChatRoomInfo({Key? key,  required this.privateChatroomId, required this.userData, required this.myData}) : super(key: key);

  @override
  State<PrivateChatRoomInfo> createState() => _PrivateChatRoomInfoState();
}

class _PrivateChatRoomInfoState extends State<PrivateChatRoomInfo> {

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
                const Center(
                  child: Text('メンバーリスト',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: widget.myData.imgData != '' ? Image.memory(
                        base64Decode(widget.myData.imgData),
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
                    title: Text(widget.myData.name),
                    subtitle: Text('${widget.myData.grade} ${widget.myData.group}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.myData.status,
                          style: TextStyle(
                            color: _attendanceColor(widget.myData.status)
                          ),
                        ),
                        Text(widget.myData.location,),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: widget.userData.imgData != '' ? Image.memory(
                        base64Decode(widget.userData.imgData),
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
                    title: Text(widget.userData.name),
                    subtitle: Text('${widget.userData.grade} ${widget.userData.group}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.userData.status,
                          style: TextStyle(
                              color: _attendanceColor(widget.userData.status)
                          ),
                        ),
                        Text(widget.userData.location,),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _attendanceColor(String text){
    if (text == '一時退席'){
      return Colors.yellow;
    }
    else if (text == '出席'){
      return Colors.green;
    }
    else if(text == '欠席'){
      return Colors.red;
    }
    else if(text == '帰宅'){
      return Colors.grey;
    } else if (text == '授業中') {
      return Colors.purple;
    } else {
      return Colors.blue;
    }
  }

}