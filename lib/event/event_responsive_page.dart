import 'package:flutter/material.dart';
import '../widget/responsive_widget.dart';
import 'event_page_web.dart';
import 'index/event_index_page_mobile.dart';

//イベント管理ページのレスポンシブ

class EventPageTop extends StatelessWidget {
  const EventPageTop({super.key});
  @override
  Widget build(BuildContext context) {
    //変更点
    //Themeウィジェットで囲む（イベントページはpurpleに）
    return Theme(
      data: ThemeData(
        useMaterial3: true, // Material 3 を有効化
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple),
      ),
      child: const ResponsiveWidget(
        //従来通りのUI
        mobileWidget: EventPageMobile(),
        //Web用のUI
        webWidget: EventPageWeb(),
      ),
    );
  }
}