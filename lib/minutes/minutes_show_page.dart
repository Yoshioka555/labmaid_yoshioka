import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:labmaidfastapi/header_footer_drawer/footer.dart';
import 'package:labmaidfastapi/minutes/minutes_edit_page.dart';
import 'package:labmaidfastapi/minutes/minutes_main_text_page.dart';

import '../domain/memo_data.dart';
import '../network/url.dart';

class MemoListShow extends StatefulWidget {
  final List<MemoData> memoList;
  const MemoListShow({super.key, required this.memoList});

  @override
  State<MemoListShow> createState() => _MemoListShow();
}

class _MemoListShow extends State<MemoListShow> {
  int _selectedIndex = 0;
  // 最大アイテム数 / 10 (1ページの表示数)
  int _maxPage = 0;
  // 全アイテム数
  int _itemCount = 0;
  // ボタンサイズ
  final double _buttonSize = 40;
  // 選択の色
  final Color _selectedColor = Colors.green;
  // 非選択の色
  final Color _notSelectColor = Colors.amber;

  String mainText = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> getMinute(MemoData memo) async {
    var uri = Uri.parse('${httpUrl}meetings/${memo.id}');
    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // main_textデータを取得
      mainText = responseData['main_text'];

      // mainTextを利用する処理
      print(mainText);

      // 取得したデータを使用する
    } else {
      print('リクエストが失敗しました: ${response.statusCode}');
      // リクエストが失敗した場合の処理
    }
  }

  Future delete(MemoData memo) async {
    var uri = Uri.parse('${httpUrl}meetings/${memo.id}');
    final response = await http.delete(uri);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${memo.title}が削除されました。',
            style: const TextStyle(color: Colors.green),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${memo.title}の削除に失敗しました。',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0.0,
        title: const Text('議事録一覧',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: (widget.memoList.isEmpty) ?
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      )
          : _pageNationBottomBar(widget.memoList),

    );
  }

  Widget _pageNationButton(Color color, Function function, Widget widget) {
    return Container(
      height: _buttonSize,
      width: _buttonSize,
      color: color,
      margin: const EdgeInsets.all(2),
      child: InkWell(
        onTap: () {
          setState(
                () {
              function();
              // ↑何かしらのイベントを呼ぶ（APIとか）
            },
          );
        },
        child: Center(child: widget),
      ),
    );
  }

  Widget _pageNationBottomBar(List<MemoData> memoList) {
    // サンプル数
    _itemCount = memoList.length;

    // ページの最大数
    if(_itemCount % 10 == 0) {
      _maxPage = _itemCount ~/10;
    }
    else {
      _maxPage = _itemCount ~/10 + 1;
    }

    // 現在のページから前後1ページを表示する
    // ただし、先頭、末尾の時は前後1個多く表示する
    final beforecurrentPageCount = (_selectedIndex == _maxPage - 1) ? 2 : 1;
    final startPageToEndPageCount = beforecurrentPageCount * 2 + 1;

    final startpage =
    1 < _selectedIndex ? _selectedIndex - beforecurrentPageCount : 0;
    final endpage = startpage + startPageToEndPageCount < _maxPage
        ? startpage + startPageToEndPageCount
        : _maxPage;

    List<Widget> widget = [];

    // 先頭の矢印
    if (_selectedIndex != 0 && _maxPage > 1) {
      widget.add(
        _pageNationButton(
          Colors.blue,
              () {
            _selectedIndex--;
          },
          const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      );
    }

    // 1と「・・・」
    if (_selectedIndex > 0) {
      if (startpage > 0) {
        widget.add(
          _pageNationButton(
            _notSelectColor,
                () {
              _selectedIndex = 0;
            },
            const Text(
              '1',
            ),
          ),
        );
      }
      if (_selectedIndex > 2) {
        widget.add(
          Container(
            height: _buttonSize,
            width: _buttonSize,
            color: Colors.transparent,
            margin: const EdgeInsets.all(2),
            child: const Center(
              child: Icon(
                Icons.keyboard_control_outlined,
                color: Colors.black,
              ),
            ),
          ),
        );
      }
    }

    for (var i = startpage; i < endpage; i++) {
      widget.add(
        _pageNationButton(
          (i == _selectedIndex) ? _selectedColor : _notSelectColor,
              () {
            _selectedIndex = i;
          },
          Text(
            (i + 1).toString(),
          ),
        ),
      );
    }

    // _maxPageと「・・・」
    if (_maxPage - 1 > _selectedIndex) {
      if (_maxPage - 3 > _selectedIndex) {
        widget.add(
          Container(
            height: _buttonSize,
            width: _buttonSize,
            color: Colors.transparent,
            margin: const EdgeInsets.all(2),
            child: const Center(
              child: Icon(
                Icons.keyboard_control_outlined,
                color: Colors.black,
              ),
            ),
          ),
        );
      }

      if (_maxPage > endpage) {
        widget.add(
          _pageNationButton(
            _notSelectColor,
                () {
              _selectedIndex = _maxPage - 1;
            },
            Text(
              _maxPage.toString(),
            ),
          ),
        );
      }
    }

    // 末尾の矢印
    if (_selectedIndex != _maxPage - 1 && _maxPage > 1) {
      widget.add(
        _pageNationButton(
          Colors.blue,
              () {
            _selectedIndex++;
          },
          const Icon(Icons.arrow_forward_ios_outlined),
        ),
      );
    }

    List<MemoData> pageMemoList = [];



    if(memoList.length % 10 != 0 && _selectedIndex == memoList.length ~/ 10) {
      pageMemoList = memoList.getRange(_selectedIndex*10, memoList.length).toList();

    }
    else {
      pageMemoList = memoList.getRange(_selectedIndex*10, _selectedIndex*10 + 10).toList();

    }

    DateFormat outputDate = DateFormat('yyyy年MM月dd日(EEE) a hh:mm');

    final List<Widget> widgets = pageMemoList.map(
          (memo) => Slidable(
        key: ValueKey(memo.id),  // ユニークなキーを使用

        // 左側のアクションペイン
            /*
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
          ],
        ),

             */

        // 右側のアクションペイン
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('削除の確認'),
                      content: const Text(
                        'この議事録を削除しますか？',
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
                            await delete(memo);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Footer(pageNumber: 3)
                            ),
                            );
                          },
                          child: const Text('削除する'),
                        ),
                      ],
                    );
                  },
                );

              }, // ここに適切な削除処理を追加
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
            SlidableAction(
              onPressed: (BuildContext context) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => EditMemoPage(memo),
                  ),
                );

              }, // 編集機能を実装する場合ここを変更
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),

        // Slidableの子ウィジェット、ユーザーがドラッグしていないときに表示されるもの
        child: ListTile(
          title: Text('${memo.title} ${memo.team}'),
          subtitle: Text('${outputDate.format(memo.createdAt)} 製作者名 ${memo.userName}'),
          trailing: IconButton(
            icon: const Icon(Icons.login_outlined),
            onPressed: () async {
              await getMinute(memo);
              // MainText遷移
              MemoData newMemo = MemoData(
                  id: memo.id, title: memo.title,
                  createdAt: memo.createdAt,
                  team: memo.team, mainText: mainText,
                  kinds: memo.kinds, userId: memo.userId,
                  userName: memo.userName
              );

              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => MainTextPage(memo: newMemo),
                  ),
              );
            },
          ),
        ),
      ),
    ).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: widgets,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget,
        ),
        const SizedBox(height: 50,)
      ],
    );
  }

}


