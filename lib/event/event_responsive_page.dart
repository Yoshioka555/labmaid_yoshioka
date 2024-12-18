import 'package:flutter/material.dart';

import '../widget/responsive_widget.dart';
import 'index/event_index_page.dart';
import 'event_page_web.dart';

//変更点
//このページはコピペ

//イベント管理ページのレスポンシブ

class EventPageTop extends StatelessWidget {
  const EventPageTop({super.key});
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true, // Material 3 を有効化
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple),//イベントページのテーマカラーを設定（purple）
      ),
      child: const ResponsiveWidget(
        //従来通りのUI
        mobileWidget: EventIndexPage(),
        //Web用のUI
        webWidget: EventPageWeb(),
      ),
    );
  }
}