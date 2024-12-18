import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:labmaidfastapi/services/background_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'header_footer_drawer/footer.dart'; // フッターページのインポート
import 'login/login_page.dart'; // ログインページのインポート
import 'package:flutter/foundation.dart';
import 'firebase_options.dart'; // Firebaseオプションのインポート
import 'shared/constants.dart'; // 定数のインポート

Future<void> main() async {
  // Flutterエンジンが初期化されるまで待機
  WidgetsFlutterBinding.ensureInitialized();

  // Webプラットフォームの場合、Firebaseを初期化
  if(kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: Constants.apiKey,
          appId: Constants.appId,
          messagingSenderId: Constants.messagingSenderId,
          projectId: Constants.projectId,
        )
    );
  }
  // その他のプラットフォームの場合、デフォルトのFirebaseオプションを使用して初期化
  else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // 位置情報の許可をリクエスト
    await requestLocationPermission();
    await initializeBackgroundService(); // バックグラウンドサービスの初期化
  }

  // MyAppウィジェットをルートとして実行
  runApp(
    const MyApp()
  );
}

Future<void> requestLocationPermission() async {
  // フォアグラウンドの位置情報権限をリクエスト
  var locationStatus = await Permission.location.status;
  if (locationStatus.isDenied) {
    locationStatus = await Permission.location.request();
  }

  // フォアグラウンド位置情報が許可されている場合のみ、バックグラウンドの権限をリクエスト
  if (locationStatus.isGranted) {
    var backgroundStatus = await Permission.locationAlways.status;
    if (backgroundStatus.isDenied) {
      backgroundStatus = await Permission.locationAlways.request();
    }

    if (backgroundStatus.isGranted) {
      print("バックグラウンドでの位置情報アクセスが許可されました。");
    } else {
      print("バックグラウンドでの位置情報アクセスが拒否されました。");
    }
  } else {
    print("位置情報のアクセスが拒否されました。");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // ローカライズデリゲートの設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // サポートされるロケールの設定
      supportedLocales: const [
        Locale('ja', ''), // 日本語
      ],
      locale: const Locale('ja'), // デフォルトロケールを日本語に設定
      //変更点
      //ここを変えたらブラウザのタブの名前が変わる？
      //Flutter Demo から Labmaid に変更
      title: 'Labmaid', // アプリのタイトル
      debugShowCheckedModeBanner: false,
      // デバッグモードのバナーを非表示
      //テーマを白にして、マテリアルデザイン３を適応しています
      //テキストエラーや背景色を設定しなくても、自動的にいい感じの色味にしてくれる
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        ),
        //MaterialDesign3
        useMaterial3: true,
      ),
      scrollBehavior: const ScrollBehavior().copyWith(
        // スクロールデバイスの設定
        dragDevices: {
          PointerDeviceKind.trackpad,
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      home: StreamBuilder<User?>(
        // Firebase Authの状態を監視するStreamBuilder
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // 接続状態が待機中の場合、空のSizedBoxを表示
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // ユーザーが認証されている場合、フッターページを表示(ログイン維持機能)
          if (snapshot.hasData) {
            return const Footer(pageNumber: 0);
          }
          // ユーザーが認証されていない場合、ログインページを表示
          return const LoginPage();
        },
      ),
    );
  }
}
