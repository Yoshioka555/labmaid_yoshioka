import 'package:flutter/material.dart';
import '../../door_status/door_status_appbar.dart';
import '../../gemini/gemini_chat_page.dart';
import '../../geo_location/location_member_index.dart';
import '../../header_footer_drawer/drawer.dart';
import 'event_index_page_web.dart';

//モバイル版イベントページ

class EventPageMobile extends StatelessWidget {
  const EventPageMobile({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      drawer: const UserDrawer(),
      body: const EventIndexPageWeb(),
    );
  }
}