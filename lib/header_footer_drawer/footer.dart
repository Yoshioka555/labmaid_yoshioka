import 'package:flutter/material.dart';
import 'package:labmaidfastapi/chat/chatroom_index_page.dart';
import 'package:labmaidfastapi/location/member_indoor_location.dart';
import 'package:labmaidfastapi/minutes/minutes_index_page.dart';

import '../attendance/attendance_page_responsive.dart';
import '../event/event_responsive_page.dart';
import '../user/my_page.dart';

//変更点
//コピペで

class Footer extends StatefulWidget {

  final int pageNumber;
  const Footer({super.key, required this.pageNumber});

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late int _selectedIndex;
  final _bottomNavigationBarItems = <BottomNavigationBarItem>[];

  //アイコン情報
  static const _footerIcons = [
    Icons.calendar_month,
    Icons.groups,
    Icons.chat,
    Icons.edit_note,
    Icons.location_pin,
    Icons.account_circle,
  ];

  //アイコン文字列
  static const _footerItemNames = [
    'イベント',
    '出席管理',
    'チャット',
    '議事録',
    '位置情報',
    'マイページ',
  ];

  //アイコンや文字列のカラー
  final List<Color?> _footerItemColor = [
    Colors.purple[300],
    Colors.green[300],
    Colors.orange[300],
    Colors.blue[300],
    Colors.teal[300],
    Colors.pink[200],
  ];

  final _routes = [
    const EventPageTop(),
    const AttendancePageTop(),
    const ChatRoomListPage(),
    const MemoListPage(),
    const MemberLocation(),
    const MyPage(),
  ];

  @override
  void initState() {
    _selectedIndex = widget.pageNumber;
    super.initState();
    for ( var i =0; i < _footerItemNames.length; i++) {
      if(_selectedIndex != i) {
        _bottomNavigationBarItems.add(_UpdateDeactiveState(i));
      }
      else {
        _bottomNavigationBarItems.add(_UpdateActiveState(_selectedIndex));
      }
    }
  }

  // インデックスのアイテムをアクティベートする
  BottomNavigationBarItem _UpdateActiveState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _footerIcons[index],
        color: _footerItemColor[index],
      ),
      label: _footerItemNames[index],

    );
  }

  // インデックスのアイテムをディアクティベートする
  BottomNavigationBarItem _UpdateDeactiveState(int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _footerIcons[index],
        color: Colors.black26,
      ),
      label: _footerItemNames[index],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavigationBarItems[_selectedIndex] = _UpdateDeactiveState(_selectedIndex);
      _bottomNavigationBarItems[index] = _UpdateActiveState(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _routes.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,  //これを書かないと３つまでしか表示されない
          items: _bottomNavigationBarItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}