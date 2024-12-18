import 'package:flutter/material.dart';
import 'package:labmaidfastapi/attendance/index/attendance_index_page_day.dart';
import 'package:labmaidfastapi/attendance/index/attendance_index_page_month.dart';

import '../door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import '../geo_location/location_member_index.dart';
import '../header_footer_drawer/drawer.dart';
import 'index/attendance_index_page_week.dart';
import 'user_management/attendance_management_page.dart';

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
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
                text: 'Member',
              ),
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
        body: const TabBarView(
          children: [
            AttendanceManagementPage(),
            AttendanceIndexPageMonth(),
            AttendanceIndexPageWeek(),
            AttendanceIndexPageDay(),
          ],
        ),
      ),
    );
  }
}
