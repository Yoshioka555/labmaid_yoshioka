import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/attendance_data.dart';
import '../../network/url.dart';
import '../update/attendance_update_page.dart';

class AttendanceIndexPageDay extends StatefulWidget {
  const AttendanceIndexPageDay({Key? key}) : super(key: key);

  @override
  _AttendanceIndexPageDayState createState() => _AttendanceIndexPageDayState();
}

class _AttendanceIndexPageDayState extends State<AttendanceIndexPageDay> {
  final CalendarController _controllerDay = CalendarController();
  late CalendarHeaderStyle _headerStyle;
  late WebSocketChannel _channel;

  List<AttendanceData> attendances = [];
  int? id;

  bool _isDisposed = false;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime today = DateTime.now();

  CalendarHeaderStyle headerStyle(DateTime date) {
    if (date.month == 1) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.blue,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 2) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.cyan,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 3) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.teal,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 4) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.green,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 5) {
      return CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.lightGreenAccent.shade700,
        textStyle: const TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 6) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.amber,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 7) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.orange,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 8) {
      return CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.deepOrange.shade600,
        textStyle: const TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 9) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.pinkAccent,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 10) {
      return const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.purpleAccent,
        textStyle: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.normal,
          letterSpacing: 5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (date.month == 11) {
      return const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.purple,
          textStyle: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.normal,
            letterSpacing: 5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ));
    } else {
      return const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.indigo,
          textStyle: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.normal,
            letterSpacing: 5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ));
    }
  }

  @override
  void initState() {
    _controllerDay.displayDate =
        DateTime(today.year, today.month, today.day, 0, 0, 0, 0);
    _headerStyle = headerStyle(DateTime.now());
    _fetchAttendance();
    _fetchMyUserData();
    _connectWebSocket();
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true; // disposeが呼ばれたことを示すフラグを設定
    _channel.sink.close();
    super.dispose();
  }

//ダミーデータ
  void _loadDummyData() {
    setState(() {
      attendances = [
        AttendanceData(
          id: 1,
          title: '遅刻',
          description: 'プロジェクト進捗会議',
          start: DateTime(2024, 12, 14, 0, 0),
          end: DateTime(2024, 12, 14, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 101,
          userName: '山田',
        ),
        AttendanceData(
          id: 2,
          title: '欠席',
          description: 'プレゼン用資料の準備',
          start: DateTime(2024, 12, 14, 0, 0),
          end: DateTime(2024, 12, 14, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 102,
          userName: '佐藤',
        ),
        AttendanceData(
          id: 3,
          title: '早退',
          description: 'コードレビューと議論',
          start: DateTime(2024, 12, 14, 14, 0),
          end: DateTime(2024, 12, 14, 23, 0),
          undecided: true,
          mailSend: false,
          userId: 103,
          userName: '田中',
        ),
        AttendanceData(
          id: 1,
          title: '遅刻',
          description: 'プロジェクト進捗会議',
          start: DateTime(2024, 12, 15, 0, 0),
          end: DateTime(2024, 12, 15, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 101,
          userName: '山田',
        ),
        AttendanceData(
          id: 2,
          title: '欠席',
          description: 'プレゼン用資料の準備',
          start: DateTime(2024, 12, 15, 0, 0),
          end: DateTime(2024, 12, 15, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 102,
          userName: '佐藤',
        ),
        AttendanceData(
          id: 3,
          title: '早退',
          description: 'コードレビューと議論',
          start: DateTime(2024, 12, 15, 14, 0),
          end: DateTime(2024, 12, 15, 23, 0),
          undecided: true,
          mailSend: false,
          userId: 103,
          userName: '田中',
        ),
        AttendanceData(
          id: 1,
          title: '遅刻',
          description: 'プロジェクト進捗会議',
          start: DateTime(2024, 12, 16, 14, 0),
          end: DateTime(2024, 12, 16, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 101,
          userName: '山田',
        ),
        AttendanceData(
          id: 2,
          title: '欠席',
          description: 'プレゼン用資料の準備',
          start: DateTime(2024, 12, 16, 0, 0),
          end: DateTime(2024, 12, 16, 23, 0),
          undecided: false,
          mailSend: false,
          userId: 102,
          userName: '佐藤',
        ),
        AttendanceData(
          id: 3,
          title: '早退',
          description: 'コードレビューと議論',
          start: DateTime(2024, 12, 16, 15, 0),
          end: DateTime(2024, 12, 16, 23, 0),
          undecided: true,
          mailSend: false,
          userId: 103,
          userName: '田中',
        ),
      ];
    });
  }

  Future<void> _fetchAttendance() async {
    //ダミーデータを参照
    _loadDummyData();
    /*
    var uri = Uri.parse('${httpUrl}attendances');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      setState(() {
        attendances =
            body.map((dynamic json) => AttendanceData.fromJson(json)).toList();
      });

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
    */
  }

  Future<void> _fetchMyUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    var uriUser = Uri.parse('${httpUrl}user_id/$userId');
    var responseUser = await http.get(uriUser);

    // レスポンスのステータスコードを確認
    if (responseUser.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseUser.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      setState(() {
        id = responseData['id'];
      });

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${responseUser.statusCode}');
    }
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPersistentFrameCallback((duration) {
      if (!mounted) return; // ウィジェットがマウントされているか確認
      if (_isDisposed) return; // フラグをチェック
      var midDate = viewChangedDetails
          .visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
      setState(() {
        _headerStyle = headerStyle(midDate);
      });
    });
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_attendance_list'),
    );
    _channel.stream.listen((message) {
      // JSONデータをデコード
      var messageData = jsonDecode(message);
      if (messageData['action'] == 'create') {
        final attendance = AttendanceData.fromJson(messageData);
        setState(() {
          attendances.add(attendance);
        });
      } else if (messageData['action'] == 'delete') {
        setState(() {
          attendances
              .removeWhere((attendance) => attendance.id == messageData['id']);
        });
      } else if (messageData['action'] == 'update') {
        for (int i = 0; i < attendances.length; i++) {
          if (attendances[i].id == messageData['id']) {
            setState(() {
              attendances[i].title = messageData['title'] as String;
              attendances[i].description = messageData['description'] as String;
              attendances[i].start =
                  DateTime.parse(messageData['start'] as String);
              attendances[i].end = DateTime.parse(messageData['end'] as String);
              attendances[i].undecided = messageData['undecided'] as bool;
              attendances[i].mailSend = messageData['mail_send'] as bool;
            });
            break;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 1100,
              child: SfCalendar(
                dataSource: AttendanceDataSource(attendances),
                view: CalendarView.day,
                controller: _controllerDay,
                cellEndPadding: 0,
                headerDateFormat: 'yyyy年　MM月',
                showNavigationArrow: true,
                onViewChanged: viewChanged,
                headerStyle: _headerStyle,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: _headerStyle.backgroundColor,
                  dayTextStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                todayHighlightColor: Colors.indigo,
                appointmentBuilder:
                    (BuildContext context, CalendarAppointmentDetails details) {
                  final AttendanceData appointment = details.appointments.first;
                  final bool isTimeslotAppointment = _isTimeslotAppointmentView(
                      appointment, _controllerDay.view);
                  final bool isStartAppointment = !isTimeslotAppointment &&
                      _isStartOfAppointmentView(appointment, details.date);
                  final bool isEndAppointment = !isTimeslotAppointment &&
                      _isEndOfAppointmentView(
                          appointment, details.date, _controllerDay.view);
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateAttendancePage(
                            attendance: appointment,
                            currentUserId: id!,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Tooltip(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      richMessage: WidgetSpan(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appointment.userName}：${appointment.title}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '詳細：${appointment.description}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          appointment.title == '遅刻'
                              ? appointment.undecided
                                  ? const Text(
                                      '到着時刻未定',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '${DateFormat.Hm('ja').format(appointment.start)}頃到着予定',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    )
                              : appointment.title == '早退'
                                  ? Text(
                                      '${DateFormat.Hm('ja').format(appointment.start)}頃早退予定',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const SizedBox(),
                        ],
                      )),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(isStartAppointment ? 0 : 0,
                            0, isEndAppointment ? 0 : 0, 0),
                        decoration: BoxDecoration(
                          color: _isTitleToColorBox(appointment.title),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _isTitleToColorBorder(appointment.title),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            '${appointment.userName}：${appointment.title}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///祝日(手打ち)
  List<DateTime> holidays = [
    DateTime(2022, 01, 01),
    DateTime(2022, 01, 10),
    DateTime(2022, 02, 11),
    DateTime(2022, 02, 23),
    DateTime(2022, 03, 21),
    DateTime(2022, 04, 29),
    DateTime(2022, 05, 03),
    DateTime(2022, 05, 04),
    DateTime(2022, 05, 05),
    DateTime(2022, 07, 18),
    DateTime(2022, 08, 11),
    DateTime(2022, 09, 19),
    DateTime(2022, 09, 23),
    DateTime(2022, 10, 10),
    DateTime(2022, 11, 03),
    DateTime(2022, 11, 23),
    DateTime(2023, 01, 01),
    DateTime(2023, 01, 02),
    DateTime(2023, 01, 09),
    DateTime(2023, 02, 11),
    DateTime(2023, 02, 23),
    DateTime(2023, 03, 21),
    DateTime(2023, 04, 29),
    DateTime(2023, 05, 03),
    DateTime(2023, 05, 04),
    DateTime(2023, 05, 05),
    DateTime(2023, 07, 17),
    DateTime(2023, 08, 11),
    DateTime(2023, 09, 18),
    DateTime(2023, 09, 23),
    DateTime(2023, 10, 09),
    DateTime(2023, 11, 03),
    DateTime(2023, 11, 23),
    DateTime(2024, 01, 01),
    DateTime(2024, 01, 08),
    DateTime(2024, 02, 11),
    DateTime(2024, 02, 12),
    DateTime(2024, 02, 23),
    DateTime(2024, 03, 20),
    DateTime(2024, 04, 29),
    DateTime(2024, 05, 03),
    DateTime(2024, 05, 04),
    DateTime(2024, 05, 05),
    DateTime(2024, 05, 06),
    DateTime(2024, 07, 15),
    DateTime(2024, 08, 11),
    DateTime(2024, 09, 16),
    DateTime(2024, 09, 22),
    DateTime(2024, 09, 23),
    DateTime(2024, 10, 14),
    DateTime(2024, 11, 03),
    DateTime(2024, 11, 23),
    DateTime(2025, 01, 01),
    DateTime(2025, 01, 13),
    DateTime(2025, 02, 11),
    DateTime(2025, 02, 23),
    DateTime(2025, 03, 20),
    DateTime(2025, 04, 29),
    DateTime(2025, 05, 03),
    DateTime(2025, 05, 04),
    DateTime(2025, 05, 05),
    DateTime(2025, 05, 06),
    DateTime(2025, 07, 21),
    DateTime(2025, 08, 11),
    DateTime(2025, 09, 15),
    DateTime(2025, 09, 23),
    DateTime(2025, 10, 13),
    DateTime(2025, 11, 03),
    DateTime(2025, 11, 23),
    DateTime(2025, 11, 24),
    DateTime(2026, 01, 01),
    DateTime(2026, 01, 12),
    DateTime(2026, 02, 11),
    DateTime(2026, 02, 23),
    DateTime(2026, 03, 20),
    DateTime(2026, 04, 29),
    DateTime(2026, 05, 03),
    DateTime(2026, 05, 04),
    DateTime(2026, 05, 05),
    DateTime(2026, 05, 06),
    DateTime(2026, 07, 20),
    DateTime(2026, 08, 11),
    DateTime(2026, 09, 21),
    DateTime(2026, 09, 22),
    DateTime(2026, 09, 23),
    DateTime(2026, 10, 12),
    DateTime(2026, 11, 03),
    DateTime(2026, 11, 23),
    DateTime(2027, 01, 01),
    DateTime(2027, 01, 11),
    DateTime(2027, 02, 11),
    DateTime(2027, 02, 23),
    DateTime(2027, 03, 21),
    DateTime(2027, 03, 22),
    DateTime(2027, 04, 29),
    DateTime(2027, 05, 03),
    DateTime(2027, 05, 04),
    DateTime(2027, 05, 05),
    DateTime(2027, 07, 19),
    DateTime(2027, 08, 11),
    DateTime(2027, 09, 20),
    DateTime(2027, 09, 23),
    DateTime(2027, 10, 11),
    DateTime(2027, 11, 03),
    DateTime(2027, 11, 23),
    DateTime(2028, 1, 1),
    DateTime(2028, 1, 10),
    DateTime(2028, 2, 11),
    DateTime(2028, 2, 23),
    DateTime(2028, 3, 20),
    DateTime(2028, 4, 29),
    DateTime(2028, 5, 3),
    DateTime(2028, 5, 4),
    DateTime(2028, 5, 5),
    DateTime(2028, 7, 17),
    DateTime(2028, 8, 11),
    DateTime(2028, 9, 18),
    DateTime(2028, 9, 22),
    DateTime(2028, 10, 9),
    DateTime(2028, 11, 3),
    DateTime(2028, 11, 23),
    DateTime(2029, 1, 1),
    DateTime(2029, 1, 8),
    DateTime(2029, 2, 11),
    DateTime(2029, 2, 12),
    DateTime(2029, 2, 23),
    DateTime(2029, 3, 20),
    DateTime(2029, 4, 29),
    DateTime(2029, 4, 30),
    DateTime(2029, 5, 3),
    DateTime(2029, 5, 4),
    DateTime(2029, 5, 5),
    DateTime(2029, 7, 16),
    DateTime(2029, 8, 11),
    DateTime(2029, 9, 17),
    DateTime(2029, 9, 23),
    DateTime(2029, 9, 24),
    DateTime(2029, 10, 8),
    DateTime(2029, 11, 3),
    DateTime(2029, 11, 23),
    DateTime(2030, 1, 1),
    DateTime(2030, 1, 14),
    DateTime(2030, 2, 11),
    DateTime(2030, 2, 23),
    DateTime(2030, 3, 20),
    DateTime(2030, 4, 29),
    DateTime(2030, 5, 3),
    DateTime(2030, 5, 4),
    DateTime(2030, 5, 5),
    DateTime(2030, 5, 6),
    DateTime(2030, 7, 15),
    DateTime(2030, 8, 11),
    DateTime(2030, 8, 12),
    DateTime(2030, 9, 16),
    DateTime(2030, 9, 23),
    DateTime(2030, 10, 14),
    DateTime(2030, 11, 3),
    DateTime(2030, 11, 4),
    DateTime(2030, 11, 23),
  ];

  Color _isTitleToColorBox(String title) {
    if (title == '遅刻') {
      return Colors.amber.withOpacity(0.4);
    } else if (title == '欠席') {
      return Colors.red.withOpacity(0.4);
    } else {
      return Colors.brown.withOpacity(0.4);
    }
  }

  Color _isTitleToColorBorder(String title) {
    if (title == '遅刻') {
      return Colors.orange;
    } else if (title == '欠席') {
      return Colors.red;
    } else {
      return Colors.brown;
    }
  }

  /// Check whether the appointment placed inside the timeslot on day, week
  /// and work week views.
  bool _isTimeslotAppointmentView(AttendanceData app, CalendarView? view) {
    return (view == CalendarView.day ||
            view == CalendarView.week ||
            view == CalendarView.workWeek) &&
        app.end.difference(app.start).inDays < 1;
  }

  /// Check the date values are equal based on day, month and year.
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check the appointment view is start of an appointment.
  bool _isStartOfAppointmentView(AttendanceData app, DateTime date) {
    return _isSameDate(app.start, date);
  }

  /// Check the appointment view is end of an appointment.
  bool _isEndOfAppointmentView(
      AttendanceData app, DateTime date, CalendarView? view) {
    if (view == CalendarView.month ||
        view == CalendarView.timelineWeek ||
        view == CalendarView.timelineWorkWeek ||
        view == CalendarView.week ||
        view == CalendarView.workWeek) {
      const int firstDayOfWeek = DateTime.sunday; // denotes the sunday weekday.

      /// Calculate the start date of the current week based on the builder
      /// date and first day of week.
      int value = -date.weekday + firstDayOfWeek - DateTime.daysPerWeek;
      if (value.abs() >= DateTime.daysPerWeek) {
        value += DateTime.daysPerWeek;
      }

      /// Current week start date.
      final DateTime weekStartDate = date.add(Duration(days: value));
      DateTime weekEndDate =
          weekStartDate.add(const Duration(days: DateTime.daysPerWeek - 1));
      weekEndDate = DateTime(
          weekEndDate.year, weekEndDate.month, weekEndDate.day, 23, 59, 59);

      /// Check the appointment end date is on or before the week end date.
      return weekEndDate.isAfter(app.start) ||
          _isSameDate(app.end, weekEndDate);
    } else if (view == CalendarView.schedule ||
        view == CalendarView.timelineDay ||
        view == CalendarView.day) {
      /// In calendar day, timeline day and schedule views
      /// are rendered based on each day, so we need to check the builder
      /// date value with appointment end date value for identify
      /// the end of the appointment.
      return _isSameDate(app.end, date);
    } else if (view == CalendarView.timelineMonth) {
      /// In calendar timeline month view render based month value so we need
      /// to check the builder date month and year value with appointment end
      /// date month and year value for identify the end of the appointment.
      return app.end.month == date.month && app.end.year == date.year;
    }
    return false;
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class AttendanceDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  AttendanceDataSource(List<AttendanceData> source) {
    appointments = source;
  }

  @override
  int getId(int index) {
    return _getAttendanceData(index).id;
  }

  @override
  DateTime getStartTime(int index) {
    return _getAttendanceData(index).start;
  }

  @override
  DateTime getEndTime(int index) {
    return _getAttendanceData(index).end;
  }

  @override
  String getSubject(int index) {
    return _getAttendanceData(index).title;
  }

  AttendanceData _getAttendanceData(int index) {
    final dynamic attendance = appointments![index];
    late final AttendanceData attendanceData;
    if (attendance is AttendanceData) {
      attendanceData = attendance;
    }
    return attendanceData;
  }
}
