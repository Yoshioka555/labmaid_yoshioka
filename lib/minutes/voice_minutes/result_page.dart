import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:labmaidfastapi/domain/memo_data.dart';

import '../../network/url.dart';
import '../minutes_pdf_preview.dart';
import 'call_chatgpt.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen(this.mozi, this.memo, {super.key});

  final MemoData memo;
  final String mozi;

  //学生ごとに文字起こしテキストを分割
  List<String> separate(mozi) {
    final reg = RegExp(
        r'何かありますか|これ結構声張ったほうがいいんですか|他ありますか|ほかありますか|なにかありますか|君いきましょうか|君行きましょうか|くん行きましょうか|くんいきましょうか|よろしいですか|次.くん|次..くん|次...くん|次....くん|次.....くん|それじゃあこの調子でやってもらったらいいと思います|それじゃあ...行きましょう|それじゃあ....行きましょう|それじゃあ.....行きましょう|それじゃあ......行きましょう|それじゃあ.......行きましょう|それじゃあ........行きましょう|それじゃあ...いきましょう|それじゃあ....いきましょう|それじゃあ.....いきましょう|それじゃあ......いきましょう|それじゃあ.......いきましょう|それじゃあ........いきましょう|それでは.君の方|それでは..君の方|それでは...君の方|それでは....君の方|それでは.....君の方|それでは.君のほう|それでは..君のほう|それでは...君のほう|それでは....のほう|それでは.....君のほう|それでは.くんの方|それでは..くんの方|それでは...くんの方|それでは....くんの方|それでは.....くんの方|それでは.くんのほう|それでは..くんのほう|それでは...くんのほう|それでは....くんのほう|それでは.....くんのほう|じゃあ行きましょうか|じゃあいきましょうか|の方行きましょう|の方いきましょう|のほう行きましょう|のほういきましょう|の方に行きましょう|の方にいきましょう|のほうに行きましょう|のほうにいきましょう|最後.くん|最後..くん|最後...くん|最後....くん|最後.....くん|それじゃあ最後|それじゃ最後|それでは最後|最後になりました|お待たせしました');
    List<String> sepa = mozi.split(reg);
    return sepa;
  }

  //学生ごとに分割されたテキスト（配列）をChatGPTに要約依頼
  Future<String> processArray(List<String> inputArray) async {
    String gizi = "";

    for (int i = 0; i < inputArray.length; i++) {
      //分割が連続で行われた場合のテキストをChetGPTに送らない処理
      if (inputArray[i].isEmpty || inputArray[i].length < 30) {
      } else {
        //ChatGPTに要約をリクエスト
        String summarizedText = await sendToChatGPT(inputArray[i]);
        gizi += '$summarizedText\n----------------------------------------\n\n';
      }
    }
    return gizi;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      future: processArray(separate(mozi)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Colors.blue.shade800,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              centerTitle: true,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Call ChatGPT',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    '要約中です',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Colors.blue.shade800,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              centerTitle: true,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Call ChatGPT',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Colors.blue.shade800,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              centerTitle: true,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              title: const Text(
                '要約済み議事録',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    // PDF化してプレビューを表示する処理
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MinutesPdfPreview(
                          snapshot.data!,
                          memo.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                ),
                //保存ボタンの追加
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    // mainTextの更新
                    if (snapshot.data != null || snapshot.data != '') {
                      await updateMainText(snapshot.data!, memo.id);
                      try {
                        // mainTextの更新
                        await updateMainText(snapshot.data!, memo.id);

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        final snackBar = SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('${memo.title}の議事録の上書きをしました。'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(e.toString()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                    else {
                      const snackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('議事録が空白のため、上書きできません。'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      snapshot.data ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future updateMainText(String text, int id) async {
    final url = Uri.parse('${httpUrl}update_main_text/$id');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'main_text': text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}
