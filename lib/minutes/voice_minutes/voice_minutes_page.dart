import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../domain/memo_data.dart';
import 'call_chatgpt.dart';
import 'call_whisper.dart';
import 'result_page.dart';

//議事録の録音と生成を行うページ

//上書き録音を行う場合のダイアログで確認が行われたかどうかのbool値
bool check = true;

//最終的なテキスト(議事録)が入る変数
String minutesText = '';

class VoiceMemoPage extends StatefulWidget {
  final MemoData memo;
  const VoiceMemoPage({Key? key, required this.memo}) : super(key: key);

  @override
  State<VoiceMemoPage> createState() => _VoiceMemoPageState();
}

class AlertDialogSample extends StatefulWidget {
  const AlertDialogSample({Key? key}) : super(key: key);

  @override
  State<AlertDialogSample> createState() => _AlertDialogSampleState();
}

class _AlertDialogSampleState extends State<AlertDialogSample> {
  @override
  Widget build(BuildContext context) {
    //ダイアログ
    return AlertDialog(
      title: const Text('警告'),
      content: const Text('前回の録音が破棄されますがよろしいですか？'),
      actions: <Widget>[
        GestureDetector(
          child: const Text('戻る'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: const Text('はい'),
          onTap: () {
            setState(() {
              check = true;
            });
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

class _VoiceMemoPageState extends State<VoiceMemoPage> {
  late Record audioRecord;

  //録音中かどうか
  bool _isRecording = false;

  //一時停止中かどうか
  bool _isPausing = false;

  //Whisperからの応答を待つ
  bool _isWaiting = true;

  //録音が最低でも一度行われたか
  bool fileExist = false;

  //assetsに入れたm4aファイルを試すときのパス
  //String tempPath = '/Users/yoshioka/StudioProjects/record_demo/lib/assets/grid1-1.m4a';

  //文字起こしされたテキストを入れる
  String mainText = '';

  //一定時間で録音を切り、即座に録音を開始するためのタイマー
  Timer? _splitTimer;

  //録音した音声ファイルを格納するList、nullを避けるため0番目には'0'を入れている
  List<String> filePath = ['0'];

  //音声ファイルが複数必要になった時、加算される
  int recordNumber = 0;

  final _stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    audioRecord = Record();
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Future<void> startRecording(int num) async {
    try {
      if (await audioRecord.hasPermission()) {
        String tempPath;
        Directory appDocDirectory = await getTemporaryDirectory();
        filePath.add('${appDocDirectory.path}/myRecording$num.m4a');
        tempPath = filePath[num];
        debugPrint(tempPath);
        await audioRecord.start(
          path: tempPath,
        );
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Record Start エラー : $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await audioRecord.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      debugPrint('Record Stop エラー : $e');
    }
  }

  void splitRecording() {
    if (_isRecording) {
      setState(() {
        fileExist = true;
      });
      stopRecording();
      _stopWatchTimer.onResetTimer();
      _splitTimer?.cancel();
    } else {
      recordNumber = 1;
      _stopWatchTimer.onStartTimer();
      startRecording(recordNumber);
    }
    //35分おきに録音を切り、すぐに再開させる
    //これをしないとWhisperに送信可能な容量を超えてしまう
    _splitTimer = Timer.periodic(const Duration(minutes: 35), (_) {
      recordNumber++;
      stopRecording();
      startRecording(recordNumber);
    });
  }

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

  //Whisperで文字起こし、分割要約まで行い、返り値は最終的なテキスト(完成した議事録)となる
  Future<String> callWhisper(int num) async {
    String moziokosi = '';
    //音声ファイルが複数ある場合は何回も文字起こし依頼を出す
    for (int i = 1; i < num + 1; i++) {
      String temp = await convertSpeechToText(filePath[i]);
      moziokosi += temp;
    }
    return moziokosi;
  }

  @override
  Widget build(BuildContext context) {
    return _isWaiting
        ? Scaffold(
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
        title: const Text(
          'Audio Recorder',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

      ) ,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
                  final displayTime = StopWatchTimer.getDisplayTime(
                    milliSecond: false,
                    snapshot.data!,
                  );
                  return Text(
                    displayTime,
                    style: const TextStyle(fontSize: 40),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(

                    onPressed: () async {
                      if (_isRecording) {
                        splitRecording();
                        setState(() {
                          _isPausing = false;
                          fileExist = true;
                        });
                      } else {
                        if (check) {
                          splitRecording();
                          setState(() {
                            check = false;
                            fileExist = false;
                          });
                        } else {
                          showDialog<void>(
                              context: context,
                              builder: (_) {
                                return const AlertDialogSample();
                              });
                        }
                      }
                    },
                    child: Text(
                      _isRecording ? '録音完了' : '新規録音',
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: (_isRecording)
                        ? () async {
                      if (_isPausing) {
                        await audioRecord.resume();
                        _stopWatchTimer.onStartTimer();
                        setState(() {
                          _isPausing = false;
                        });
                      } else {
                        await audioRecord.pause();
                        _stopWatchTimer.onStopTimer();
                        setState(() {
                          _isPausing = true;
                        });
                      }
                    }
                        : null,
                    child: Text(
                      _isPausing ? '録音再開' : '一時停止',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: (fileExist)
                      ? () async {
                    setState(() {
                      _isWaiting = false;
                    });
                    await callWhisper(recordNumber).then((value) {
                      setState(() {
                        mainText = value;
                        debugPrint(mainText);
                        _isWaiting = true;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ResultScreen(mainText,widget.memo),
                        ),
                      );
                    });
                  }
                      : null,
                  child: const Text('議事録を作成する')),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    )
        : Scaffold(
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
          'Call Whisper',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text(
                '文字起こし中です',
                style: TextStyle(fontSize: 20),
              ),
            ],
          )),
    );
  }
}

