import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:labmaidfastapi/domain/user_data.dart';
import 'package:http/http.dart' as http;

import '../image_size/size_limit.dart';
import '../network/url.dart';

class AddChatRoomModel extends ChangeNotifier {
  final roomNameController = TextEditingController();

  GroupChatMember? myData;
  DateTime createdAt = DateTime.now();
  String? base64Image;
  Uint8List? imageBytes;

  bool isLoading = false;

  List<GroupChatMember> users = [];

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void itemChange(bool val, int id, List<GroupChatMember> members) {

    for (int i = 0; i < members.length; i++) {
      if (members[i].id == id) {
        // GroupChatMemberが不変（final）の場合、新しいインスタンスを作成して置き換える
        members[i] = GroupChatMember(
          id: members[i].id,
          email: members[i].email,
          group: members[i].group,
          grade: members[i].grade,
          name: members[i].name,
          status: members[i].status,
          imgData: members[i].imgData,
          firebaseUserId: members[i].firebaseUserId,
          fileName: members[i].fileName,
          join: val,  // ここで新しいjoin値を設定
        );
        break;  // 一致するIDが見つかったらループを抜ける
      }
    }
    notifyListeners();
  }

  void radioChange(List<GroupChatMember> members, String radio) {
    if(radio == '') {
      for(int i=0; i<members.length; i++) {
        members[i].join = false;
      }
      notifyListeners();
    }
    else if(radio == '全体') {
      for(int i=0; i<members.length; i++) {
        members[i].join = true;
      }
    }
    else if(radio == 'Network班') {
      for(int i=0; i<members.length; i++) {
        if(members[i].group == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'Grid班') {
      for(int i=0; i<members.length; i++) {
        if(members[i].group == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'Web班') {
      for(int i=0; i<members.length; i++) {
        if(members[i].group == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'B4') {
      for(int i=0; i<members.length; i++) {
        if(members[i].grade == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'M1') {
      for(int i=0; i<members.length; i++) {
        if(members[i].grade == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'M2') {
      for(int i=0; i<members.length; i++) {
        if(members[i].grade == radio) {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
    else if(radio == 'D') {
      for(int i=0; i<members.length; i++) {
        if(members[i].grade == 'D1' || members[i].grade == 'D2' || members[i].grade == 'D3') {
          members[i].join = true;
        }
        else {
          members[i].join = false;
        }
      }
    }
  }

  Future fetchUserList() async {
    final currentUser = FirebaseAuth.instance.currentUser;

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
      myData = GroupChatMember.fromJson(responseData);

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }


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
      users = body.map((dynamic json) => GroupChatMember.fromJson(json)).toList();

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseGet.statusCode}');
    }

    notifyListeners();
  }

  //ByteDataの取得、Uint8Listに変換
  Future<Uint8List> loadImageBytes(String imagePath) async {
    ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future addRoom(Uint8List? image) async {
    List<int> members = [];

    members.add(myData!.id);
    for(int i=0; i < users.length; i++) {
      if (users[i].join == true) {
        members.add(users[i].id);
      }
    }

    if (roomNameController.text  == '') {
      throw 'ルーム名が入力されていません。';
    }

    //FastAPIに追加
    //Postリクエストを送信するエンドポイントのURL
    var uri = Uri.parse('${httpUrl}group_chat_room');
    String imagePath = 'assets/images/group_default.jpg'; //画像ファイルパス

    final request = http.MultipartRequest('POST', uri);
    if (image == null) {
      imageBytes = await loadImageBytes(imagePath);
    } else {
      imageBytes = image;

      if (!sizeLimit(image)) {
        throw '画像サイズが2.2Mを超えているため、画像サイズは更新できませんでした。';
      }
    }

    Map<String, String> headers = {"Content-type": "multipart/form-data"};

    final file = http.MultipartFile.fromBytes(
        'file', imageBytes!, filename: 'group_default.jpg');
    request.files.add(file);
    request.headers.addAll(headers);

    request.fields.addAll({
      'name': roomNameController.text,
      'created_at': createdAt.toIso8601String(),
      'member_ids': members.join(','),
    });

    final stream = await request.send();

    final response = await http.Response.fromStream(stream);

    if (response.statusCode == 200) {
      return response.statusCode;

    } else {
      throw Exception('Failed to create group chat room: ${response.statusCode}');
    }


  }

}