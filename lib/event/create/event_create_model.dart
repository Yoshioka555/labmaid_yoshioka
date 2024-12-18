import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../network/url.dart';

class CreateEventModel extends ChangeNotifier {

  String? userId;
  String? email;
  int? id;
  String name = '';

  Future fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    email = user.email;
    var uri = Uri.parse('${httpUrl}user_name_id/$userId');
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      id = responseData['id'];
      name = responseData['name'];

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
    notifyListeners();
  }

  Future addEvent(String title, DateTime start, DateTime end, String unit, String description, bool mailSend) async {

    if (title =='') {
      throw 'タイトルが入力されていません。';
    }
    if (description == '') {
      description = '詳細なし';
    }

    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    final url = Uri.parse('${httpUrl}events');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'unit': unit,
        'description': description,
        'user_id': id,
        'mail_send': mailSend,
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

    notifyListeners();
  }

  Future sendEmail(String title, DateTime start, DateTime end, String unit, String description) async {
    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    Uri url = Uri.parse('${httpUrl}mail');
    final response = await http.post(url, body: {'name': name, 'subject': subject(title,unit), 'from_email': email, 'text': textMessages(title,start,end,unit,description)});

    if (response.statusCode == 200) {
      // POSTリクエストが成功した場合
      print('Response data: 200');
    } else {
      // POSTリクエストが失敗した場合
      print('Request failed with status: ${response.statusCode}');
    }
  }

  String textMessages(String title, DateTime start, DateTime end, String unit, String description) {
    DateTime currentDate = DateTime.now();
    if(title == 'ミーティング') {
      return '開始時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '終了時刻：${DateFormat.yMMMd('ja').format(end).toString()}(${DateFormat.E('ja').format(end)})ー${DateFormat.Hm('ja').format(end)}\n'
          '$unit $title\n'
          '作成者：$name\n'
          'メールアドレス：${email!}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
    else {
      return '開始時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '終了時刻：${DateFormat.yMMMd('ja').format(end).toString()}(${DateFormat.E('ja').format(end)})ー${DateFormat.Hm('ja').format(end)}\n'
          '$title\n'
          '作成者：$name\n'
          'メールアドレス：${email!}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
  }

  String subject(String title, String unit) {
    if (title == 'ミーティング') {
      return '$name：$unit $title';
    } else {
      return '$name：$title';
    }
  }

}

