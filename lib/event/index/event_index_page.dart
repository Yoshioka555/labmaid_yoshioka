import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:labmaidfastapi/domain/event_data.dart';
import 'package:labmaidfastapi/door_status/door_status_appbar.dart';
import 'package:labmaidfastapi/event/create/event_create_page.dart';
import 'package:labmaidfastapi/event/update/event_update_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../gemini/gemini_chat_page.dart';
import '../../geo_location/location_member_index.dart';
import '../../header_footer_drawer/drawer.dart';
import '../../network/url.dart';
import '../create/event_create_dialog.dart';

//変更点
//このページはコピペで

class EventIndexPage extends StatefulWidget {
  const EventIndexPage({Key? key}) : super(key: key);

  @override
  _EventIndexPageState createState() => _EventIndexPageState();
}

class _EventIndexPageState extends State<EventIndexPage> {
  final CalendarController _controller = CalendarController();
  final CalendarController _controllerWeek = CalendarController();
  final CalendarController _controllerDay = CalendarController();
  late CalendarHeaderStyle _headerStyle;

  late WebSocketChannel _channel;

  List<EventData> events = [];
  int? id;
  String? name;
  String? email;

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

  void _goToToday() {
    _controller.displayDate = DateTime(
      today.year,
      today.month,
      1,
    );
  }

  void _goToSelectedYearMonth(int year, int month) {
    _controller.displayDate = DateTime(year, month, 1);
  }

  @override
  void initState() {
    _controller.displayDate =
        DateTime(today.year, today.month, 1, 0, 0, 0, 0, 0);
    _controllerWeek.displayDate =
        DateTime(today.year, today.month, today.day, 0, 0, 0, 0);
    _controllerDay.displayDate =
        DateTime(today.year, today.month, today.day, 0, 0, 0, 0);
    _headerStyle = headerStyle(DateTime.now());
    _fetchEvent();
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

  Future<void> _fetchEvent() async {
    var uri = Uri.parse('${httpUrl}events');

    // GETリクエストを送信
    var response = await http.get(uri);

    // レスポンスのステータスコードを確認
    if (response.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(response.bodyBytes);

      // JSONデータをデコード
      final List<dynamic> body = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          events =
              body.map((dynamic json) => EventData.fromJson(json)).toList();
        });
      }

      // 取得したデータを使用する
    } else {
      // リクエストが失敗した場合の処理
      print('リクエストが失敗しました: ${response.statusCode}');
    }
  }

  Future<void> _fetchMyUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    setState(() {
      email = user.email;
    });

    var uriUser = Uri.parse('${httpUrl}user_name_id/$userId');
    var responseUser = await http.get(uriUser);

    // レスポンスのステータスコードを確認
    if (responseUser.statusCode == 200) {
      // レスポンスボディをUTF-8でデコード
      var responseBody = utf8.decode(responseUser.bodyBytes);

      // JSONデータをデコード
      var responseData = jsonDecode(responseBody);

      // 必要なデータを取得
      if (mounted) {
        setState(() {
          id = responseData['id'];
          name = responseData['name'];
        });
      }

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
      Uri.parse('${wsUrl}ws_event_list'),
    );
    _channel.stream.listen((message) {
      // JSONデータをデコード
      var messageData = jsonDecode(message);
      if (messageData['action'] == 'create') {
        // 必要なデータを取得
        final event = EventData.fromJson(messageData);
        setState(() {
          events.add(event);
        });
      } else if (messageData['action'] == 'delete') {
        setState(() {
          events.removeWhere((event) => event.id == messageData['id']);
        });
      } else if (messageData['action'] == 'update') {
        for (int i = 0; i < events.length; i++) {
          if (events[i].id == messageData['id']) {
            setState(() {
              events[i].title = messageData['title'] as String;
              events[i].description = messageData['description'] as String;
              events[i].start = DateTime.parse(messageData['start'] as String);
              events[i].end = DateTime.parse(messageData['end'] as String);
              events[i].mailSend = messageData['mail_send'] as bool;
              events[i].unit = messageData['unit'] as String;
            });
            break;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50.0,
          backgroundColor: Colors.purple[100],
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GeoLocationIndexPage()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(Icons.psychology_alt),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GeminiChatPage()),
                  );
                },
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
          title: const DoorStatusAppbar(),
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(
                text: 'Month',
              ),
              Tab(
                text: 'Week',
              ),
              Tab(
                text: 'Day',
              ),
            ],
          ),
        ),
        drawer: const UserDrawer(),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _goToToday();
                                },
                                child: const Text('今日'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: DropdownButton(
                                  value: selectedYear,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 2020,
                                      child: Text('2020年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2021,
                                      child: Text('2021年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2022,
                                      child: Text('2022年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2023,
                                      child: Text('2023年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2024,
                                      child: Text('2024年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2025,
                                      child: Text('2025年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2026,
                                      child: Text('2026年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2027,
                                      child: Text('2027年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2028,
                                      child: Text('2028年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2029,
                                      child: Text('2029年'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2030,
                                      child: Text('2030年'),
                                    ),
                                  ],
                                  onChanged: (text) {
                                    setState(() {
                                      selectedYear = text!;
                                    });
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: DropdownButton(
                                  value: selectedMonth,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('1月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('2月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('3月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 4,
                                      child: Text('4月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 5,
                                      child: Text('5月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 6,
                                      child: Text('6月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 7,
                                      child: Text('7月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 8,
                                      child: Text('8月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 9,
                                      child: Text('9月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 10,
                                      child: Text('10月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 11,
                                      child: Text('11月'),
                                    ),
                                    DropdownMenuItem(
                                      value: 12,
                                      child: Text('12月'),
                                    ),
                                  ],
                                  onChanged: (text) {
                                    setState(() {
                                      selectedMonth = text!;
                                    });
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _goToSelectedYearMonth(
                                      selectedYear, selectedMonth);
                                },
                                child: const Text('移動'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1800,
                    child: SfCalendar(
                      onLongPress: (CalendarLongPressDetails details) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEventPage(
                              selectedDate: details.date!,
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      onTap: (CalendarTapDetails details) {
                        EventDialogUtils.showCustomDialog(
                          context: context,
                          selectedDate: details.date!,
                          userId: id!,
                          name: name!,
                          email: email!,
                        );
                      },
                      dataSource: EventDataSource(events),
                      view: CalendarView.month,
                      controller: _controller,
                      cellEndPadding: 0,
                      headerDateFormat: 'yyyy年MM月',
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
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      appointmentBuilder: (BuildContext context,
                          CalendarAppointmentDetails details) {
                        final EventData appointment =
                            details.appointments.first;
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateEventPage(
                                  event: appointment,
                                  content: titleToContent(appointment.title),
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
                                  _titleToolchip(
                                      appointment.title, appointment.unit),
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
                              ],
                            )),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isTitleToColorBox(
                                    appointment.title, appointment.unit),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _isTitleToColorBorder(
                                      appointment.title, appointment.unit),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  displayTitle(appointment.title,
                                      appointment.unit, appointment.start),
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
                      monthCellBuilder:
                          (BuildContext context, MonthCellDetails details) {
                        return Container(
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                              color: _getCellColor(details.date),
                              border:
                                  Border.all(color: Colors.grey, width: 0.2)),
                          child: DateTime(details.date.year, details.date.month,
                                      details.date.day) ==
                                  DateTime(today.year, today.month, today.day)
                              ? Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.indigo,
                                  ),
                                  height: 25,
                                  width: 25,
                                  alignment: Alignment.center,
                                  child: Text(
                                    details.date.day.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              : Text(
                                  details.date.day.toString(),
                                  style: TextStyle(
                                      color: _getTextColor(details.date)),
                                ),
                        );
                      },
                      monthViewSettings: const MonthViewSettings(
                        numberOfWeeksInView: 6,
                        // 表示する週の数
                        agendaItemHeight: 40,
                        appointmentDisplayCount: 7,
                        showAgenda: true,
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                        monthCellStyle: MonthCellStyle(
                          backgroundColor: Colors.white,
                        ),
                        agendaStyle: AgendaStyle(
                          backgroundColor: Colors.white,
                          dateTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          dayTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 1100,
                    child: SfCalendar(
                      dataSource: EventDataSource(events),
                      view: CalendarView.week,
                      controller: _controllerWeek,
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
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      appointmentBuilder: (BuildContext context,
                          CalendarAppointmentDetails details) {
                        final EventData appointment =
                            details.appointments.first;
                        final bool isTimeslotAppointment =
                            _isTimeslotAppointmentView(
                                appointment, _controllerWeek.view);
                        final bool isStartAppointment =
                            !isTimeslotAppointment &&
                                _isStartOfAppointmentView(
                                    appointment, details.date);
                        final bool isEndAppointment = !isTimeslotAppointment &&
                            _isEndOfAppointmentView(appointment, details.date,
                                _controllerWeek.view);
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateEventPage(
                                  event: appointment,
                                  content: titleToContent(appointment.title),
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          //Tooltip
                          //対象のwidgetをTooltipでラップする
                          //Webではマウスオーバーで表示される
                          //iosでは長押しで表示される
                          //WidgetSpanというのを使えばwidgetを入れ込める
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
                                  _titleToolchip(
                                      appointment.title, appointment.unit),
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
                              ],
                            )),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  isStartAppointment ? 0 : 0,
                                  0,
                                  isEndAppointment ? 0 : 0,
                                  0),
                              decoration: BoxDecoration(
                                color: _isTitleToColorBox(
                                    appointment.title, appointment.unit),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _isTitleToColorBorder(
                                      appointment.title, appointment.unit),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  displayTitle(appointment.title,
                                      appointment.unit, appointment.start),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 1100,
                    child: SfCalendar(
                      dataSource: EventDataSource(events),
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
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      appointmentBuilder: (BuildContext context,
                          CalendarAppointmentDetails details) {
                        final EventData appointment =
                            details.appointments.first;
                        final bool isTimeslotAppointment =
                            _isTimeslotAppointmentView(
                                appointment, _controllerDay.view);
                        final bool isStartAppointment =
                            !isTimeslotAppointment &&
                                _isStartOfAppointmentView(
                                    appointment, details.date);
                        final bool isEndAppointment = !isTimeslotAppointment &&
                            _isEndOfAppointmentView(
                                appointment, details.date, _controllerDay.view);
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateEventPage(
                                  event: appointment,
                                  content: titleToContent(appointment.title),
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          //Tooltip
                          //対象のwidgetをTooltipでラップする
                          //Webではマウスオーバーで表示される
                          //iosでは長押しで表示される
                          //WidgetSpanというのを使えばwidgetを入れ込める
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
                                  _titleToolchip(
                                      appointment.title, appointment.unit),
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
                              ],
                            )),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  isStartAppointment ? 0 : 0,
                                  0,
                                  isEndAppointment ? 0 : 0,
                                  0),
                              decoration: BoxDecoration(
                                color: _isTitleToColorBox(
                                    appointment.title, appointment.unit),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _isTitleToColorBorder(
                                      appointment.title, appointment.unit),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  displayTitle(appointment.title,
                                      appointment.unit, appointment.start),
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
          ],
        ),
      ),
    );
  }

  String titleToContent(String title) {
    if (title == 'ミーティング' || title == '輪講') {
      return title;
    } else {
      return 'その他';
    }
  }

  String displayTitle(String title, String unit, DateTime start) {
    if (title == 'ミーティング') {
      return '${DateFormat.Hm('ja').format(start)} $unitミーティング';
    } else {
      return '${DateFormat.Hm('ja').format(start)} $title';
    }
  }

  String _titleToolchip(String title, String unit) {
    if (title == 'ミーティング') {
      return '$unitミーティング';
    } else {
      return title;
    }
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

  Color _getCellColor(DateTime date) {
    DateTime displayDate = _controller.displayDate!;
    if (DateTime(date.year, date.month, 1).isBefore(
        DateTime(displayDate.year, displayDate.month, displayDate.day))) {
      return const Color(0xFFD6D6D6);
    } else if (DateTime(date.year, date.month, 1)
        .isAfter(DateTime(displayDate.year, displayDate.month + 1, 0))) {
      return const Color(0xFFD6D6D6);
    } else {
      if (holidays.contains(DateTime(date.year, date.month, date.day))) {
        return Colors.red.shade100;
      } else {
        if (date.weekday == DateTime.sunday) {
          return Colors.red.shade100;
        } else if (date.weekday == DateTime.saturday) {
          return Colors.blue.shade100;
        } else {
          return Colors.white;
        }
      }
    }
  }

  Color _getTextColor(DateTime date) {
    DateTime displayDate = _controller.displayDate!;
    if (DateTime(date.year, date.month, 1).isBefore(
        DateTime(displayDate.year, displayDate.month, displayDate.day))) {
      return Colors.grey.shade600;
    } else if (DateTime(date.year, date.month, 1)
        .isAfter(DateTime(displayDate.year, displayDate.month + 1, 0))) {
      return Colors.grey.shade600;
    } else {
      if (holidays.contains(DateTime(date.year, date.month, date.day))) {
        return Colors.red;
      } else {
        if (date.weekday == DateTime.sunday) {
          return Colors.red;
        } else if (date.weekday == DateTime.saturday) {
          return Colors.blue;
        } else {
          return Colors.black;
        }
      }
    }
  }

  //_isTitleToColorBox内のColorsに.withOpacity(0.3)をつけて色を透過
  Color _isTitleToColorBox(String title, String unit) {
    if (title == 'ミーティング') {
      if (unit == '全体') {
        return Colors.purple.withOpacity(0.3);
      } else if (unit == '個人') {
        return Colors.deepPurple.withOpacity(0.3);
      } else if (unit == 'Web班') {
        return Colors.cyan.withOpacity(0.3);
      } else if (unit == 'Net班') {
        return Colors.amber.withOpacity(0.3);
      } else if (unit == 'Grid班') {
        return Colors.lightGreen.withOpacity(0.3);
      } else if (unit == 'B4') {
        return Colors.teal.withOpacity(0.3);
      } else if (unit == 'M1') {
        return Colors.orange.withOpacity(0.3);
      } else if (unit == 'M2') {
        return Colors.blueGrey.withOpacity(0.3);
      } else {
        return Colors.red.withOpacity(0.3);
      }
    } else if (title == '輪講') {
      return Colors.indigo.withOpacity(0.3);
    } else {
      return Colors.pink.withOpacity(0.3);
    }
  }

  Color _isTitleToColorBorder(String title, String unit) {
    if (title == 'ミーティング') {
      if (unit == '全体') {
        return Colors.purple;
      } else if (unit == '個人') {
        return Colors.deepPurple;
      } else if (unit == 'Web班') {
        return Colors.cyan;
      } else if (unit == 'Net班') {
        return Colors.amber;
      } else if (unit == 'Grid班') {
        return Colors.lightGreen.shade400;
      } else if (unit == 'B4') {
        return Colors.teal;
      } else if (unit == 'M1') {
        return Colors.orange;
      } else if (unit == 'M2') {
        return Colors.blueGrey.shade400;
      } else {
        return Colors.red.shade400;
      }
    } else if (title == '輪講') {
      return Colors.indigo.shade400;
    } else {
      return Colors.pink.shade400;
    }
  }

  /// Check whether the appointment placed inside the timeslot on day, week
  /// and work week views.
  bool _isTimeslotAppointmentView(EventData app, CalendarView? view) {
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
  bool _isStartOfAppointmentView(EventData app, DateTime date) {
    return _isSameDate(app.start, date);
  }

  /// Check the appointment view is end of an appointment.
  bool _isEndOfAppointmentView(
      EventData app, DateTime date, CalendarView? view) {
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
class EventDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  EventDataSource(List<EventData> source) {
    appointments = source;
  }

  @override
  int getId(int index) {
    return _getEventData(index).id;
  }

  @override
  DateTime getStartTime(int index) {
    return _getEventData(index).start;
  }

  @override
  DateTime getEndTime(int index) {
    return _getEventData(index).end;
  }

  @override
  String getSubject(int index) {
    return _getEventData(index).title;
  }

  EventData _getEventData(int index) {
    final dynamic event = appointments![index];
    late final EventData eventData;
    if (event is EventData) {
      eventData = event;
    }
    return eventData;
  }
}
