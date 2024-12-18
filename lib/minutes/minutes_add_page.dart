import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:labmaidfastapi/domain/user_data.dart';

import '../network/url.dart';


class AddMemoPage extends StatefulWidget {
  final UserData myData;
  const AddMemoPage({Key? key, required this.myData}) : super(key: key);

  @override
  _AddMemoPageState createState() => _AddMemoPageState();
}

class _AddMemoPageState extends State<AddMemoPage> {

  String _team = 'Web班';
  late TextEditingController _titleController;
  late FocusNode _titleNode;
  String _kinds = 'ミーティング';

  @override
  void initState() {
    _titleController = TextEditingController();
    _titleController.text = '';
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
        title: const Text(
          '議事録を追加',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0.0,
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
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'タイトル',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: TextField(
                        controller: _titleController,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: '製作者名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(widget.myData.name),
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
                          try{
                            await addMemo();
                            Navigator.of(context).pop(true);
                          } catch(e) {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(e.toString()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        child: const Text('追加する')
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Future addMemo() async {
    if (_titleController.text == '') {
      throw 'タイトルが入力されていません。';
    }

    final url = Uri.parse('${httpUrl}meetings');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'created_at': DateTime.now().toIso8601String(),
        'team': _team,
        'main_text': '',
        'user_id': widget.myData.id,
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