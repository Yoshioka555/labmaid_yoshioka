import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../network/url.dart';

class DoorStatusAppbar extends StatefulWidget {
  const DoorStatusAppbar({Key? key}) : super(key: key);
  @override
  _DoorStatusAppbarState createState() => _DoorStatusAppbarState();
}

class _DoorStatusAppbarState extends State<DoorStatusAppbar> {
  late WebSocketChannel _channel;
  String _initDoorStatus = 'loading';

  @override
  void initState() {
    super.initState();
    _fetchDoorStatus();
    _channel = WebSocketChannel.connect(
      Uri.parse('${wsUrl}ws_door_status'),
    );

  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  String _imageDoorStatus(String doorStatus) {
    if (doorStatus == "unlocked") {
      return "assets/images/door_unlocked.png";
    } else if (doorStatus == "locked") {
      return "assets/images/door_locked.png";
    } else if (doorStatus == "loading") {
      return "assets/images/loading_door.png";
    } else if (doorStatus == "error") {
      return "assets/images/camera_error.png";
    } else {
      return "assets/images/error_door.png";
    }
  }

  Future<void> _fetchDoorStatus() async {
    final response = await http.get(
      Uri.parse('${httpUrl}door_status'),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _initDoorStatus = response.body.replaceAll('"', '');
        });
      }
    } else {
      setState(() {
        _initDoorStatus = "unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // 画面の幅に合わせる
      height: kToolbarHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: StreamBuilder(
          stream: _channel.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Image.asset(_imageDoorStatus(_initDoorStatus)); // データ待機中にインジケーターを表示
            } else if (snapshot.hasError) {
              return Image.asset('assets/images/error_door.png'); // エラーが発生した場合の表示
            } else if (snapshot.hasData) {
              return Image.asset(_imageDoorStatus(snapshot.data));
            } else {
              return Image.asset('assets/images/error_door.png'); // データがない場合の表示
            }
          },
        ),
      ),
    );
  }
}
