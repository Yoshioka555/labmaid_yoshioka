import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/memo_data.dart';
import '../header_footer_drawer/footer.dart';
import '../network/url.dart';

class EditMemoPage extends StatefulWidget {
  final MemoData memo;
  const EditMemoPage(this.memo, {super.key});

  @override
  _EditMemoPageState createState() => _EditMemoPageState();
}

class _EditMemoPageState extends State<EditMemoPage> {

  late String _team;
  late TextEditingController _titleController;
  late FocusNode _titleNode;
  late String _kinds;

  @override
  void initState() {
    _titleController = TextEditingController();
    _titleController.text = widget.memo.title;
    _team = widget.memo.team;
    _kinds = widget.memo.kinds;
    _titleNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _titleNode.dispose();
    super.dispose();
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
        title: const Text('議事録編集',
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
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); // フォーカスを解除
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text("ミーティング"),
                          selected: _kinds == 'ミーティング',
                          backgroundColor: Colors.grey,
                          selectedColor: Colors.purpleAccent[100],
                          onSelected: (_) {
                            setState(() {
                              _kinds = 'ミーティング';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("その他"),
                          selected: _kinds == 'その他',
                          backgroundColor: Colors.grey,
                          selectedColor: Colors.purpleAccent[100],
                          onSelected: (_) {
                            setState(() {
                              _kinds = 'その他';
                            });
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'タイトル',
                        hintText: 'タイトルを入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: '製作者名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(widget.memo.userName),
                    ),
                    RadioListTile(
                      title: const Text('Web班'),
                      value: 'Web班',
                      groupValue: _team,
                      onChanged: (value) {
                        setState(() {
                          _team = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('Net班'),
                      value: 'Net班',
                      groupValue: _team,
                      onChanged: (value) {
                        setState(() {
                          _team = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('機械学習班'),
                      value: '機械学習班',
                      groupValue: _team,
                      onChanged: (value) {
                        setState(() {
                          _team = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('時間拡大班'),
                      value: '時間拡大班',
                      groupValue: _team,
                      onChanged: (value) {
                        setState(() {
                          _team = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('All'),
                      value: 'All',
                      groupValue: _team,
                      onChanged: (value) {
                        setState(() {
                          _team = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          //model.team = _team;
                          try {
                            await update();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Footer(pageNumber: 3),
                              ),
                            );
                          } catch(e) {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(e.toString()),
                            );
                            ScaffoldMessenger.of(context).
                            showSnackBar(snackBar);
                          }
                        },
                        child: const Text('更新する')
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Future update() async {
    if (_titleController.text == '') {
      throw 'タイトルが入力されていません。';
    }

    final url = Uri.parse('${httpUrl}meetings/${widget.memo.id}');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'team': _team,
        'kinds': _kinds,
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

  }
}