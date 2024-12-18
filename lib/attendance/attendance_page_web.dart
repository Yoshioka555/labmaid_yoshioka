import 'package:flutter/material.dart';
import 'package:labmaidfastapi/attendance/attendance_home_page_web.dart';
import 'package:labmaidfastapi/attendance/user_management/attendance_management_page_web.dart';
import 'package:labmaidfastapi/door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import '../geo_location/location_member_index.dart';
import '../header_footer_drawer/drawer.dart';

//WEB用の出席管理ページ

class AttendancePageWeb extends StatelessWidget {
  const AttendancePageWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const DoorStatusAppbar(),
        //Gemini AI Page への遷移
        //仮でここに置いています
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
      ),
      drawer: const UserDrawer(),
      body: Row(
        children: [
          //Web用の予定追加ページ
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const AttendanceHomePageWeb(),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 1.0,
              child: const Column(
                children: [
                  Expanded(child: AttendanceManagementPageWeb()),
                ],
              )),
        ],
      ),
    );
  }
}
