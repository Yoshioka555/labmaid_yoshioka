import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'apikey_openai.dart';


//音声ファイルのパスを渡して、Whisperに文字起こしを行わせる関数
//返り値は文字起こしされたテキスト

Future<String> convertSpeechToText(String filePath) async {
  const apiKey = openaiApiKey;
  var url = Uri.https("api.openai.com", "v1/audio/transcriptions");

  try {
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({"Authorization": "Bearer $apiKey"});
    request.fields["model"] = 'whisper-1';
    request.fields["language"] = "ja";

    // ファイルの読み込み
    try {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } catch (e) {
      debugPrint('ファイルの読み込みに失敗しました: $e');
      return 'ファイルの読み込みに失敗しました';
    }

    // リクエストの送信
    var response = await request.send();
    var newResponse = await http.Response.fromStream(response);
    final responseData = jsonDecode(utf8.decode(newResponse.body.codeUnits));

    // ステータスコードに基づく処理
    if (response.statusCode == 200) {
      return responseData['text'];
    } else if (response.statusCode == 413) {
      debugPrint('Payload Too Large error: Whisperにおいてリクエストが大きすぎる');
      return 'Whisperで音声ファイルが大きすぎるため、文字起こしされませんでした';
    } else {
      debugPrint('Error: Whisperにおいてエラーが発生しました - Status Code: ${response.statusCode}');
      debugPrint('Response body: ${newResponse.body}');
      return 'Whisperでエラーが発生し、文字起こしされませんでした';
    }
  } catch (e) {
    // ネットワークエラーやその他の例外処理
    debugPrint('エラーが発生しました: $e');
    return 'ネットワークエラーが発生しました。もう一度お試しください。';
  }
}