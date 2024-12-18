import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/user_data.dart';
import '../network/url.dart';

class GeoLocationIndexPage extends StatefulWidget {
  const GeoLocationIndexPage({Key? key}) : super(key: key);

  @override
  GeoLocationIndexPageState createState() => GeoLocationIndexPageState();
}

class GeoLocationIndexPageState extends State<GeoLocationIndexPage> {

  late WebSocketChannel _channel;
  List<UserData> userData = [];

  @override
  void initState() {
    fetchLocationMemberList();
    _connectWebSocket();
    super.initState();
  }

  Future<void> fetchLocationMemberList() async {

    // ユーザを取得する
    var url = Uri.parse('${httpUrl}users');

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

  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_user_location'),
    );
    _channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      final int id = data['user_id'];
      final String location = data['now_location'];
      final String status = data['status'];
      for(int i=0; i<userData.length; i++) {
        if(userData[i].id == id) {
          setState(() {
            userData[i].location = location;
            userData[i].status = status;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            'リアルタイムメンバー位置表示',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.lightGreen.shade700,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: userData.isNotEmpty ? Scrollbar(
        child: ListView.builder(
          itemCount: userData.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return Container(
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
                trailing: Text(userData[index].location),
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
}
