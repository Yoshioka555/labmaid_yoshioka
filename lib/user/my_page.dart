import 'package:flutter/material.dart';
import 'package:labmaidfastapi/geo_location/location_member_index.dart';
import 'package:provider/provider.dart';
import '../door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import 'my_model.dart';
import 'dart:convert';
import '../header_footer_drawer/drawer.dart';

class MyPage extends StatefulWidget {

  const MyPage({Key? key}) : super(key: key);


  @override
  _MyPageState createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyModel>(
      create: (_) => MyModel()..fetchMyModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
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
          //変更点
          //backgroundColorをpinkに
          backgroundColor: Colors.pink[200],
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: false,
          elevation: 0.0,
          title: const DoorStatusAppbar(),
        ),
        drawer: const UserDrawer(),
        body: Consumer<MyModel>(builder: (context, model, child) {

          return SingleChildScrollView(
            child: model.myData != null
                ? Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 50,
                        backgroundImage: model.myData!.imgData != '' ? Image.memory(
                          base64Decode(model.myData!.imgData),
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) {
                            return const Icon(
                              Icons.error,
                              color: Colors.red,
                            );
                          },
                        ).image
                            : const AssetImage('assets/images/default.png'),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        model.myData!.name,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        model.myData!.email,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      ConstrainedBox(
                        //ボタンの横長の最大値の設定
                        constraints: const BoxConstraints(minHeight: 40,),
                        child: SizedBox(
                          //横長がウィンドウサイズの９割５分になる設定
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: groupColor(model.myData!.group),
                                  ),
                                  child: Text(
                                    model.myData!.group,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: gradeColor(model.myData!.grade),
                                  ),
                                  child: Text(
                                    model.myData!.grade,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: statusColor(model.myData!.status),
                                  ),
                                  child: Text(
                                    model.myData!.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            )
                : const Center(
                  child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                ),
          );
        }),
      ),
    );
  }

  Color groupColor(String group) {
    if(group=='Web班') {
      return Colors.cyan;
    } else if(group=='Network班') {
      return Colors.yellow;
    } else if(group=='教員') {
      return Colors.pinkAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  Color gradeColor(String grade) {
    if(grade=='B4') {
      return Colors.lightGreenAccent;
    } else if(grade=='M1') {
      return Colors.purple;
    } else if(grade=='M2') {
      return Colors.orange;
    } else if(grade=='教授') {
      return Colors.redAccent;
    } else {
      return Colors.teal;
    }
  }

  Color statusColor(String status) {
    if(status=='出席') {
      return Colors.green;
    } else if(status=='欠席') {
      return Colors.red;
    } else if(status=='未出席') {
      return Colors.blue;
    } else if(status=='帰宅') {
      return Colors.grey;
    } else if(status=='授業中') {
      return Colors.purple;
    } else {
      return Colors.yellow;
    }
  }

}