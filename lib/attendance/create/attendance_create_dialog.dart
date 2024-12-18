import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../network/url.dart';

class AttendanceDialogUtils {
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
          child: AttendanceDialog(selectedDate: selectedDate, userId: userId, name: name, email: email,),
        );
      },
    );
  }
}

class AttendanceDialog extends StatefulWidget {
  final DateTime selectedDate;
  final int userId;
  final String name;
  final String email;

  const AttendanceDialog({Key? key, required this.selectedDate, required this.userId, required this.name, required this.email})
      : super(key: key);

  @override
  _AttendanceDialogState createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  late ScrollController _scrollController;

  bool _isLoading = false;

  bool undecided = false;
  bool _mailSend = true;
  DateTime currentDate = DateTime.now();
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;

  DateTime startDate(String title) {
    DateTime today;
    DateTime selectDay;
    if (title == '欠席') {
      today = DateTime(currentDate.year,currentDate.month,currentDate.day,00,00,00);
      selectDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,00,00,00);
    } else {
      today = DateTime(currentDate.year,currentDate.month,currentDate.day,currentDate.hour,currentDate.minute,currentDate.second).add(const Duration(minutes: 30));
      if ( DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day) == DateTime(currentDate.year, currentDate.month, currentDate.day) ) {
        selectDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,currentDate.hour,currentDate.minute,currentDate.second).add(const Duration(minutes: 30));
      } else {
        selectDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,12,00,00);
      }
    }

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
    _titleController.text = '遅刻';
    _descriptionController = TextEditingController();
    selectedStartDate = startDate('遅刻');
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

  void reset(String content) {
    if (content == '欠席') {
      setState(() {
        selectedStartDate = startDate(content);
        selectedEndDate = endDate();
      });
    } else {
      setState(() {
        selectedStartDate = startDate(content);
        selectedEndDate = endDate();
      });
    }
  }

  void resetUndecided(bool undecided) {
    if (undecided == true) {
      setState(() {
        selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,00,00,00);
      });
    } else {
      if (DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day) == DateTime(currentDate.year,currentDate.month,currentDate.day)) {
        selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,currentDate.hour,currentDate.minute,00);
        setState(() {
          selectedStartDate = selectedStartDate.add(const Duration(minutes: 30));
        });
      }
      else {
        setState(() {
          selectedStartDate = DateTime(selectedStartDate.year,selectedStartDate.month,selectedStartDate.day,12,00,00);
        });
      }
    }
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
                        value: _titleController.text,
                        items: const [
                          DropdownMenuItem(
                            value: '遅刻',
                            child: Text('遅刻'),
                          ),
                          DropdownMenuItem(
                            value: '欠席',
                            child: Text('欠席'),
                          ),
                          DropdownMenuItem(
                            value: '早退',
                            child: Text('早退'),
                          ),
                        ],
                        onChanged: (text) {
                          setState(() {
                            _titleController.text = text.toString();
                          });
                          reset(_titleController.text);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                _titleDateTime(_titleController.text),
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
                    hintText: "Attendance Description",
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
                            await addAttendance(_titleController.text, selectedStartDate, selectedEndDate, _descriptionController.text, _mailSend, undecided);
                            if (_mailSend == true) {
                              await sendEmail(_titleController.text, selectedStartDate, selectedEndDate, _descriptionController.text, undecided);
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

  Widget _titleDateTime(String title) {
    if (title == '遅刻') {
      return Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('遅刻予定日',
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
              child: Text('${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDatePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,
                  // 選択できる日時の範囲
                  minTime: DateTime(currentDate.year,currentDate.month,currentDate.day),
                  maxTime: DateTime(2030, 12, 31),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = DateTime(dateTime.year,dateTime.month,dateTime.day,12,00,00);
                      selectedEndDate = DateTime(dateTime.year,dateTime.month,dateTime.day,23,00,00);
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
                Text('到着予定時刻',
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
            child: undecided ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                    value: undecided,
                    onChanged: (value) {
                      setState(() {
                        undecided = value!;
                      });
                      resetUndecided(undecided);
                    }
                ),
                const Text(
                  '未定',
                  style: TextStyle(fontSize: 17,),
                ),
              ],
            )
            : Row(
              children: [
                TextButton(
                  child: Text(DateFormat.Hm('ja').format(selectedStartDate),
                    style: const TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  onPressed: () {
                    DatePicker.showTimePicker(
                      context,
                      // 現在の日時
                      currentTime: selectedStartDate,
                      showSecondsColumn: false,

                      // ドラムロールを変化させたときの処理
                      onChanged: (dateTime) {
                      },

                      // 「完了」を押したときの処理
                      onConfirm: (dateTime) {
                        setState(() {
                          selectedStartDate = dateTime;
                          if (selectedStartDate.isAfter(selectedEndDate)) {
                            selectedEndDate = selectedStartDate;
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
                Checkbox(
                    value: undecided,
                    onChanged: (value) {
                      setState(() {
                        undecided = value!;
                      });
                      resetUndecided(undecided);
                    }
                ),
                const Text(
                  '未定',
                  style: TextStyle(fontSize: 17,),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (title == '早退') {
      return Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('早退予定日',
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
              child: Text('${DateFormat.yMMMd('ja').format(selectedStartDate).toString()}(${DateFormat.E('ja').format(selectedStartDate)})',
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showDatePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,
                  // 選択できる日時の範囲
                  minTime: DateTime(currentDate.year,currentDate.month,currentDate.day),
                  maxTime: DateTime(2030, 12, 31),

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = DateTime(dateTime.year,dateTime.month,dateTime.day,12,00,00);
                      selectedEndDate = DateTime(dateTime.year,dateTime.month,dateTime.day,23,00,00);
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
                Text('早退予定時刻',
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
              child: Text(DateFormat.Hm('ja').format(selectedStartDate),
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              onPressed: () {
                DatePicker.showTimePicker(
                  context,
                  // 現在の日時
                  currentTime: selectedStartDate,

                  showSecondsColumn: false,
                  // 選択できる日時の範囲

                  // ドラムロールを変化させたときの処理
                  onChanged: (dateTime) {
                  },

                  // 「完了」を押したときの処理
                  onConfirm: (dateTime) {
                    setState(() {
                      selectedStartDate = dateTime;
                      if (selectedStartDate.isAfter(selectedEndDate)) {
                        selectedEndDate = selectedStartDate;
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
        ],
      );
    } else {
      return Column(
        children: [
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
        ],
      );
    }
  }

  Future addAttendance(String title, DateTime start, DateTime end, String description, bool mailSend, bool undecided) async {

    if (title =='') {
      throw 'タイトルが入力されていません。';
    }
    if (description == '') {
      throw '詳細が入力されていません。';
    }

    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    final now = DateTime.now();
    final urlUser = Uri.parse('${httpUrl}update_user_status/${widget.userId}');
    // 送信するデータを作成
    Map<String, dynamic> data = {
      'status': title,
      // 他のキーと値を追加
    };
    // リクエストヘッダーを設定
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON形式のデータを送信する場合
      // 他のヘッダーを必要に応じて追加
    };

    final url = Uri.parse('${httpUrl}attendances');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'description': description,
        'user_id': widget.userId,
        'mail_send': mailSend,
        'undecided': undecided,
      }),

    );

    if (response.statusCode == 200) {
      // POSTリクエストが成功した場合
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');

      // 今日の日付の欠席なら、Userデータを更新する
      if (title == '欠席' && start.year == now.year && start.month == now.month && start.day == now.day) {

        try {
          // HTTP POSTリクエストを送信
          final response = await http.patch(
            urlUser,
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
      }
    } else {
      // POSTリクエストが失敗した場合
      print('Request failed with status: ${response.statusCode}');
    }

  }

  Future sendEmail(String title, DateTime start, DateTime end, String description, bool undecided) async {
    if (start.isAfter(end)) {
      end = start.add(const Duration(hours: 1));
    }

    Uri url = Uri.parse('${httpUrl}mail');
    final response = await http.post(url, body: {'name': widget.name, 'subject': subject(title), 'from_email': widget.email, 'text': textMessages(title,start,end,description, undecided)});

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
            '作成者：${widget.name}\n'
            'メールアドレス：${widget.email}\n\n'
            '$description\n'
            'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
      } else {
        return '到着予定時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
            '$title\n'
            '作成者：${widget.name}\n'
            'メールアドレス：${widget.email}\n\n'
            '$description\n'
            'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
      }
    } else if(title == '早退') {
      return '早退予定時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '$title\n'
          '作成者：${widget.name}\n'
          'メールアドレス：${widget.email}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    } else {
      return '開始時刻：${DateFormat.yMMMd('ja').format(start).toString()}(${DateFormat.E('ja').format(start)})ー${DateFormat.Hm('ja').format(start)}\n'
          '終了時刻：${DateFormat.yMMMd('ja').format(end).toString()}(${DateFormat.E('ja').format(end)})ー${DateFormat.Hm('ja').format(end)}\n'
          '$title\n'
          '作成者：${widget.name}\n'
          'メールアドレス：${widget.email}\n\n'
          '$description\n'
          'メール送信日：${DateFormat.yMMMd('ja').format(currentDate).toString()}(${DateFormat.E('ja').format(currentDate)})\n';
    }
  }

  String subject(String title) {
    return '${widget.name}：$title';
  }
}
