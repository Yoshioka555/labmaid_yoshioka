import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'apikey_openai.dart';


//テキストを与えてChatGPTを呼び出し、要約結果を返す関数

Future<String> sendToChatGPT(String text) async {
  String tempText = '';
  String returnText = '';

  //ChatGPTが2000文字以上は要約してくれないので、1700＋αで分割
  List<String> extractStrings(String text) {
    List<String> result = [];
    int currentIndex = 1700;

    if (currentIndex < text.length) {
      while (currentIndex + 150 < text.length) {
        // 移動後の位置から' 'か'。'が見つかるまでの文字列を取得
        int end = currentIndex;
        while (end < text.length && text[end] != ' ' && text[end] != '。') {
          end++;
        }

        // 取得した文字列を結果配列に格納
        result.add(text.substring(currentIndex - 1700, end));

        // さらに1800文字分移動
        currentIndex = end + 1700;
      }
      result.add(text.substring(currentIndex - 1700, text.length));
    } else {
      result.add(text);
    }

    return result;
  }

  List<String> chunks = extractStrings(text);

  for (int i = 0; i < chunks.length; i++) {
    final response = await post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openaiApiKey',
        'Content-Type': 'application/json',
        // 'OpenAI-Organization': 'org-3kJ8f2NS5osyB5W4JgEzVpha',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": "以下の制約条件に従って、与えられたテキストから議事録を生成しなさい。"
                "テキストは会議の音声をWhisperを用いて文字起こしされたものである。"
                "制約条件1：’議事録の内容のみ’を返答すること。他の文は一才必要ない。\n"
                "制約条件2：議事録に敬語を使わないこと。\n"
                "制約条件3：議事録は元のテキストの 10 ％程度の文量で書くこと。\n"
                "制約条件4：議事録は文頭に- をつけて箇条書きにして書くこと。\n"
                "例\n"
                "- あいうえお\n"
                "- かきくけこ\n"
                "- さしすせそ\n"
          },
          {
            "role": "user",
            "content": chunks[i],
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.body.codeUnits))
      as Map<String, dynamic>;
      tempText = (jsonResponse['choices'] as List).first['message']['content']
      as String;
      returnText += '$tempText\n';
    } else {
      debugPrint('ChatGPT null error');
      tempText = 'ChatGPT null error\n';
      returnText += tempText;
    }
  }

  return returnText;
}