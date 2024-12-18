import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../network/url.dart';

class EventDialogUtils {
  static void showCustomDialog({
    required BuildContext context,
    required DateTime selectedDate,
    required int userId,
    required String name,
    required String email,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Popup',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: EventDialog(selectedDate: selectedDate, userId: userId, name: name, email: email,),
        );
      },
    );
  }
}

class EventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final int userId;
  final String name;
  final String email;

  const EventDialog({Key? key, required this.selectedDate, required this.userId, required this.name, required this.email})
      : super(key: key);

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late ScrollController _scrollController;

  bool _isLoading = false;

  String _content = "ミーティング";
  String _unit = '全体';
  bool _display = false;
  bool _mailSend = true;
  DateTime currentDate = DateTime.now();
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;

  DateTime startDate() {
    DateTime today = DateTime(currentDate.year,currentDate.month,currentDate.day,00,00,00);
    DateTime selectDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,00,00,00);
    if (selectDay.isBefore(today)) {
      return today;
    } else {
      return selectDay;
    }
  }

  DateTime endDate() {
    DateTime today = DateTime(currentDate.year,currentDate.month,currentDate.day,23,00,00);
    DateTime selectDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,23,00,00);
    if (selectDay.isBefore(today)) {
      return today;
    } else {
      return selectDay;
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _titleController = TextEditingController();
    _titleController.text = 'ミーティング';
    _descriptionController = TextEditingController();
    selectedStartDate = startDate();
    selectedEndDate = endDate();
    _descriptionNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _descriptionNode.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          controller: _scrollController, // ScrollControllerを指定
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController, // ScrollControllerを指定
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(),
                  ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('内容',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xffb3b9ed),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      DropdownButton(
                        value: _content,
                        items: const [
                          DropdownMenuItem(
                            value: 'ミーティング',
                            child: Text('ミーティング'),
                          ),
                          DropdownMenuItem(
                            value: '輪講',
                            child: Text('輪講'),
                          ),
                          DropdownMenuItem(
                            value: 'その他',
                            child: Text('その他'),
                          ),
                        ],
                        onChanged: (text) {
                          setState(() {
                            _content = text.toString();
                            if (text.toString() == 'ミーティング') {
                              _display = false;
                              _titleController.text = 'ミーティング';
                            }
                            if (text.toString() == '輪講') {
                              _display = false;
                              _titleController.text = '輪講';
                            }
                            if (text.toString() == 'その他') {
                              _display = true;
                              _titleController.text = '';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('タイトル',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ).copyWith(
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xfff96c6c),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    hintText: "Event Title",
                    hintStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    helperStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    errorStyle: const TextStyle(
                      color: Color(0xfff96c6c),
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                  ).copyWith(),
                  style: const TextStyle(
                    color: Color(0xff626262),
                    fontSize: 17.0,
                  ),
                  enabled: _display,

                  validator: (value) {
                    if (_titleController.text == "") {
                      return "Please enter event title.";
                    }

                    return null;
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15.0,
                ),
                unitSelector(_content),
                const SizedBox(
                  height: 15,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('開始時刻',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xffb3b9ed),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Text('${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})ー${DateFormat.Hm('ja').format(selectedStartDate)}',
                      style: const TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                      DatePicker.showDateTimePicker(
                        context,
                        // 現在の日時
                        currentTime: selectedStartDate,
                        // 選択できる日時の範囲
                        minTime: DateTime(currentDate.year,currentDate.month,currentDate.day,0,0,0),
                        maxTime: DateTime(2030, 12, 31,23,0,0),

                        // ドラムロールを変化させたときの処理
                        onChanged: (dateTime) {
                        },

                        // 「完了」を押したときの処理
                        onConfirm: (dateTime) {
                          setState(() {
                            selectedStartDate = dateTime;
                            if (selectedStartDate.isAfter(selectedEndDate)) {
                              selectedEndDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,23,00,00);
                            }
                          });
                        },

                        // 「キャンセル」を押したときの処理
                        onCancel: () {
                        },
                        //言語
                        locale: LocaleType.jp,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('終了時刻',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color(0xffb3b9ed),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Text('${DateFormat.yMMMd('ja').format(selectedEndDate).toString()}(${DateFormat.E('ja').format(selectedEndDate)})ー${DateFormat.Hm('ja').format(selectedEndDate)}',
                      style: const TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                      DatePicker.showDateTimePicker(
                        context,
                        // 現在の日時
                        currentTime: selectedEndDate,
                        // 選択できる日時の範囲
                        minTime: selectedStartDate,
                        maxTime: DateTime(2030, 12, 31),

                        // ドラムロールを変化させたときの処理
                        onChanged: (dateTime) {
                        },

                        // 「完了」を押したときの処理
                        onConfirm: (dateTime) {
                          setState(() {
                            selectedEndDate = dateTime;
                          });
                        },

                        // 「キャンセル」を押したときの処理
                        onCancel: () {
                        },
                        //言語
                        locale: LocaleType.jp,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('詳細',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  focusNode: _descriptionNode,
                  controller: _descriptionController,
                  style: const TextStyle(
                    color: Color(0xff626262),
                    fontSize: 17.0,
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  selectionControls: MaterialTextSelectionControls(),
                  minLines: 1,
                  maxLines: 10,
                  maxLength: 1000,
                  validator: (value) {
                    if (value == null || value.trim() == "") {
                      return "Please enter attendance description.";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ).copyWith(
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xfff96c6c),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Color(0xffb3b9ed),
                      ),
                    ),
                    hintText: "Attendance Title",
                    hintStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    helperStyle: const TextStyle(
                      color: Color(0xff626262),
                      fontSize: 17,
                    ),
                    errorStyle: const TextStyle(
                      color: Color(0xfff96c6c),
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                  ).copyWith(
                    hintText: "Event Description",
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        'メール送信',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: _mailSend,
                        onChanged: (value) {
                          setState(() {
                            _mailSend = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 戻るボタン
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // 戻るボタンの色
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                        child: const Text(
                          '戻る',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // 登録ボタン
                    ElevatedButton(
                      onPressed: () async {
                        _toggleLoading();
                        Future.delayed(const Duration(seconds: 1), () async {
                          _toggleLoading();
                          try {
                            //イベント追加
                            await addEvent(_titleController.text, selectedStartDate, selectedEndDate, _unit,_descriptionController.text, _mailSend, );
                            if (_mailSend == true) {
                              await sendEmail(_titleController.text, selectedStartDate, selectedEndDate, _unit,_descriptionController.text, );
                            }

                            Navigator.of(context).pop();
                            const snackBar = SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('イベントの登録をしました。'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } catch (e) {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(e.toString()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // 登録ボタンの色
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: const Text(
                        '登録',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget unitSelector(String content) {
    if (content == 'ミーティング'){
      return Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('参加単位',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color(0xffb3b9ed),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                      value: _unit,
                      items: const [
                        DropdownMenuItem(
                          value: '全体',
                          child: Text('全体'),
                        ),
                        DropdownMenuItem(
                          value: '個人',
                          child: Text('個人'),
                        ),
                        DropdownMenuItem(
                          value: 'Net班',
                          child: Text('Net班'),
                        ),
                        DropdownMenuItem(
                          value: 'Grid班',
                          child: Text('Grid班'),
                        ),
                        DropdownMenuItem(
                          value: 'Web班',
                          child: Text('Web班'),
                        ),
                        DropdownMenuItem(
                          value: 'B4',
                          child: Text('B4'),
                        ),
                        DropdownMenuItem(
                          value: 'M1',
                          child: Text('M1'),
                        ),
                        DropdownMenuItem(
                          value: 'M2',
                          child: Text('M2'),
                        ),
                      ],
                      onChanged: (text) {
                        setState(() {
                          _unit = text.toString();
                        });
                      }
                  ),
                ]),
          ),
        ],
      );
    }
    else {
      return const SizedBox();
    }
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
        'user_id': widget.userId,
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
  }

  Future sendEmail(String title, DateTime start, DateTime end, String unit, String description) async {
    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    Uri url = Uri.parse('${httpUrl}mail');
    final response = await http.post(url, body: {'name': widget.name, 'subject': subject(title,unit), 'from_email': widget.email, 'text': textMessages(title,start,end,unit,description)});

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
          '作成者：${widget.name}\n'
          'メールアドレス：${widget.email}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
    else {
      return '開始時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '終了時刻：${DateFormat.yMMMd('ja').format(end).toString()}(${DateFormat.E('ja').format(end)})ー${DateFormat.Hm('ja').format(end)}\n'
          '$title\n'
          '作成者：${widget.name}\n'
          'メールアドレス：${widget.email}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
  }

  String subject(String title, String unit) {
    if (title == 'ミーティング') {
      return '${widget.name}：$unit $title';
    } else {
      return '${widget.name}：$title';
    }
  }
}
