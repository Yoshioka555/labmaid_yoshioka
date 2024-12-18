import 'package:flutter/material.dart';
import 'package:labmaidfastapi/attendance/index/attendance_index_page_day.dart';
import 'package:labmaidfastapi/attendance/index/attendance_index_page_month.dart';

import 'index/attendance_index_page_week.dart';

class AttendanceHomePageWeb extends StatefulWidget {
  const AttendanceHomePageWeb({
    Key? key,
  }) : super(key: key);

  @override
  State<AttendanceHomePageWeb> createState() => _AttendanceHomePageWebState();
}

class _AttendanceHomePageWebState extends State<AttendanceHomePageWeb> {

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
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0.0,
          elevation: 0.0,
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(text: 'Month',),
              Tab(text: 'Week',),
              Tab(text: 'Day',),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AttendanceIndexPageMonth(),
            AttendanceIndexPageWeek(),
            AttendanceIndexPageDay(),
          ],
        ),
      ),
    );
  }
}
