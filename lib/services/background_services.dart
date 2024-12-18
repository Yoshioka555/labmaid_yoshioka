import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../network/url.dart';
import '../user/shared_preferences.dart';

Future initializeBackgroundService() async {

  final service = FlutterBackgroundService();

  // バックグラウンドサービスの設定
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,  // Androidでのバックグラウンド処理
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,  // iOSでフォアグラウンド時の処理
      onBackground: onIosBackground,  // iOSでバックグラウンド時の処理
    ),
  );
}

// バックグラウンドで実行する関数
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService() == false) {
        return;
      }
    }

    // 位置情報を取得してPOSTする処理
    await postLocation();
  });
}

Future<Position?> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 位置情報の権限が拒否された場合
      print('位置情報の権限が拒否されました。');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // 永久に拒否されている場合
    print('位置情報の権限が永久に拒否されています。');
    return null;
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return position;
}

double distanceInMeters(Position target, LatLng center) {
  return Geolocator.distanceBetween(center.latitude, center.longitude, target.latitude, target.longitude);
}

String _checkDistance(Position position) {
  const center = LatLng(34.77513, 135.51208);
  const mealCenter = LatLng(34.77441, 135.51176);
  const libraryCenter = LatLng(34.77496, 135.51013);
  const forthCenter = LatLng(34.77358, 135.51256);
  const labCenter = LatLng(34.77456, 135.51286);
  const stationCenter = LatLng(34.77094, 135.50615);

  double centerDistance = distanceInMeters(position, center);
  double mealDistance = distanceInMeters(position, mealCenter);
  double libraryDistance = distanceInMeters(position, libraryCenter);
  double forthDistance = distanceInMeters(position, forthCenter);
  double labDistance = distanceInMeters(position, labCenter);
  double stationDistance = distanceInMeters(position, stationCenter);

  String newLocation;
  if (stationDistance <= 100) {
    newLocation = '関大前駅周辺';
  } else if (labDistance <= 10) {
    newLocation = '研究室周辺';
  } else if (forthDistance <= 100) {
    newLocation = '第４学舎周辺';
  } else if (libraryDistance <= 20) {
    newLocation = '図書館周辺';
  } else if (mealDistance <= 10) {
    newLocation = '凛風館周辺';
  } else if (centerDistance <= 340) {
    newLocation = 'キャンパス内';
  } else {
    newLocation = 'キャンパス外';
  }

  return newLocation;

}

// 位置情報をサーバに送信する関数
Future<void> postLocation() async {
  try {
    final position = await getCurrentLocation();
    String location;
    if (position == null) {
      // 位置情報が許可されていない場合は「キャンパス外」に設定
      location = 'キャンパス外';
    } else {
      // 位置情報が許可されている場合は通常の処理
      location = _checkDistance(position);
    }
    String? firebaseUserId = await getUserData();

    // wi-fiの取得
    final info = NetworkInfo();
    final wifiBSSID = await info.getWifiBSSID();

    print(wifiBSSID);
    print(firebaseUserId);

    if (firebaseUserId != null) {

      // ios版のal:0:1a:eb:b4:50:90, al5GHz:0:1a:eb:b4:50:91
      if (wifiBSSID == '0:1a:eb:b4:50:90' || wifiBSSID == '0:1a:eb:b4:50:91') {
        location = '研究室内';
      }
      // android版のal:00:1a:eb:b4:50:90, al5GHz:00:1a:eb:b4:50:91
      // al: 00:1a:eb:b4:50:80
      if (wifiBSSID == '00:1a:eb:b4:50:90' || wifiBSSID == '00:1a:eb:b4:50:91') {
        location = '研究室内';
      }
      if (wifiBSSID == 'ac:44:f2:c0:30:70') {
        location = '第２研究室内';
      }
      if (wifiBSSID == '18:c2:bf:8f:d9:1c') {
        location = '榎原先生の自室';
      }

      // サーバに位置情報をPOST
      var uri = Uri.parse('${httpUrl}update_user_location/$firebaseUserId');

      // 送信するデータを作成
      Map<String, dynamic> data = {
        'now_location': location,
        // 他のキーと値を追加
      };

      // リクエストヘッダーを設定
      Map<String, String> headers = {
        'Content-Type': 'application/json', // JSON形式のデータを送信する場合
        // 他のヘッダーを必要に応じて追加
      };

      // HTTP POSTリクエストを送信
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data), // データをJSON形式にエンコード
      );

      // レスポンスをログに出力（デバッグ用）
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

    }

  } catch (e) {
    print('Error while fetching location: $e');
  }
}

// iOSのバックグラウンド処理
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  await postLocation();
  return true;
}
