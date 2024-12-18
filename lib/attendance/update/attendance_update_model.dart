import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../network/url.dart';

class UpdateAttendanceModel extends ChangeNotifier {

  String? firebaseUserId;
  String? email;
  int? userId;
  String name = '';

  Future fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    firebaseUserId = user!.uid;
    email = user.email;
    var uri = Uri.parse('${httpUrl}user_name_id/$firebaseUserId');
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      userId = responseData['id'];
      name = responseData['name'];

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }

    notifyListeners();
  }



  Future updateAttendance(int id, String title, DateTime start, DateTime end, String description, bool mailSend, bool undecided) async {

    if (title =='') {
      throw 'タイトルが入力されていません。';
    }
    if (description == '') {
      throw '詳細が入力されていません。';
    }

    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    var uri = Uri.parse('${httpUrl}attendances/$id');

    // 送信するデータを作成
    Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'mail_send': mailSend,
      'undecided': undecided,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'user_id': userId,
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

    notifyListeners();
  }

  Future deleteAttendance(int id) async {
    var uri = Uri.parse('${httpUrl}attendances/$id');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      // 成功時の処理
      print('Attendance deleted successfully');
    } else {
      // エラー時の処理
      print('Failed to delete the attendance');
    }
    notifyListeners();
  }

  Future sendEmail(String title, DateTime start, DateTime end, String description, bool undecided) async {
    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    Uri url = Uri.parse('${httpUrl}mail');
    final response = await http.post(url, body: {'name': name, 'subject': subject(title), 'from_email': email, 'text': textMessages(title,start,end,description, undecided)});

    if (response.statusCode == 200) {
      // POSTリクエストが成功した場合
      print('Response data: 200');
    } else {
      // POSTリクエストが失敗した場合
      print('Request failed with status: ${response.statusCode}');
    }
  }

  String textMessages(String title, DateTime start, DateTime end, String description, bool undecided) {
    DateTime currentDate = DateTime.now();
    if(title == '遅刻') {
      if (undecided == true) {
        return '遅刻予定日：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})\n'
            '到着予定時刻：未定\n'
            '$title\n'
            '作成者：$name\n'
            'メールアドレス：${email!}\n\n'
            '$description\n'
            'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
      } else {
        return '到着予定時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
            '$title\n'
            '作成者：$name\n'
            'メールアドレス：${email!}\n\n'
            '$description\n'
            'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
      }
    } else if(title == '早退') {
      return  '早退予定時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '$title\n'
          '作成者：$name\n'
          'メールアドレス：${email!}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    } else {
      return '開始時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '終了時刻：${DateFormat.yMMMd('ja').format(end).toString()}(${DateFormat.E('ja').format(end)})ー${DateFormat.Hm('ja').format(end)}\n'
          '$title\n'
          '作成者：$name\n'
          'メールアドレス：${email!}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
  }

  String subject(String title) {
    return '$name：$title';
  }


}

