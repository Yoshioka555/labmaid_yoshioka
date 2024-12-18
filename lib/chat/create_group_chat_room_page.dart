import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labmaidfastapi/header_footer_drawer/footer.dart';
import 'package:provider/provider.dart';

import '../domain/user_data.dart';
import '../pick_export/pick_image_export.dart';
import 'create_group_chat_room_model.dart';


class AddRoomPage extends StatefulWidget {
  const AddRoomPage({Key? key}) : super(key: key);

  @override
  State<AddRoomPage> createState() => _AddRoomPage();

}

class _AddRoomPage extends State<AddRoomPage> {

  String _group = '全体';

  Uint8List? imageData;

  void _handleRadioButton(String group) =>
      setState(() {
        _group = group;
      });

  List<GroupChatMember> getMembersByGroup(List<GroupChatMember> users, String targetGroup) {
    return users.where((user) => user.group == targetGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddChatRoomModel>(
      create: (_) => AddChatRoomModel()..fetchUserList(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.clear, color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('ルーム作成',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Consumer<AddChatRoomModel>(builder: (context, model, child) {
          final List<Widget> netMembersList = getMembersByGroup(model.users, "Network班").asMap().entries.map((member)
          => Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.yellowAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(member.value.name),
                    ),
                  ),
                  Expanded(
                    child: Checkbox(value: member.value.join,
                        onChanged: (bool? val){
                          model.itemChange(val!, member.value.id, model.users);
                        }),
                  )
                ],
              ),
            ),
          ),
          ).toList();

          final List<Widget> gridMembersList = getMembersByGroup(model.users, "Grid班").asMap().entries.map((member)
          => Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.greenAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(member.value.name),
                    ),
                  ),
                  Expanded(
                    child: Checkbox(value: member.value.join,
                        onChanged: (bool? val){
                          model.itemChange(val!, member.value.id, model.users);
                        }),
                  )
                ],
              ),
            ),
          ),
          ).toList();

          final List<Widget> webMembersList = getMembersByGroup(model.users, "Web班").asMap().entries.map((member)
          => Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.lightBlueAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(member.value.name),
                    ),
                  ),
                  Expanded(
                    child: Checkbox(value: member.value.join,
                        onChanged: (bool? val){
                          model.itemChange(val!, member.value.id, model.users);
                        }),
                  )
                ],
              ),
            ),
          ),
          ).toList();

          final List<Widget> teacherMembersList = getMembersByGroup(model.users, "教員").asMap().entries.map((member)
          => Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.purpleAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(member.value.name),
                    ),
                  ),
                  Expanded(
                    child: Checkbox(value: member.value.join,
                        onChanged: (bool? val){
                          model.itemChange(val!, member.value.id, model.users);
                        }),
                  )
                ],
              ),
            ),
          ),
          ).toList();

          return model.myData != null ?
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // フォーカスを解除
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.white
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                //getImageFromGallery();
                                final _imageData = await PickImage().pickImage();
                                setState(() {
                                  imageData = _imageData;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 50,
                                backgroundImage: imageData != null ? Image.memory(imageData!).image : const AssetImage('assets/images/group_default.jpg'),
                              ),
                            ),
                          ),
                          Text(
                            'ルーム作成者：${model.myData!.name}',
                            style: const TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          const Text('チャットルーム名',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          TextFormField(
                            controller: model.roomNameController,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: const BorderSide(
                                  width: 2,
                                  color: Colors.black87,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: const BorderSide(
                                  width: 2,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          const Text(
                            'ルーム作成日時',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy/MM/dd(EEE) a hh:mm').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          const Text('チャットルームへ招待',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: '全体',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('全体'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Network班',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('Net班'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Grid班',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('Grid班'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Web班',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('Web班'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'B4',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('B4'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'M1',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('M1'),),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'M2',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('M2'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'D',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('D'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: '',
                                      groupValue: _group,
                                      onChanged: (text) {
                                        _handleRadioButton(text!);
                                        model.radioChange(model.users, _group);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('OFF'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: netMembersList,
                          ),
                          Row(
                            children: gridMembersList,
                          ),
                          Row(
                            children: webMembersList,
                          ),
                          Row(
                            children: teacherMembersList,
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () async {

                                try {
                                  await model.addRoom(imageData);
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) {
                                          return const Footer(pageNumber: 2);
                                        }
                                    ),
                                  );

                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('チャットルームを追加しました'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } catch (e) {
                                  //失敗した場合
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(e.toString()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } finally {
                                  model.endLoading();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff6471e9),
                                  borderRadius: BorderRadius.circular(7.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xff626262),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                      spreadRadius: -3,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Create Room',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ) : const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          );
        }),
      ),
    );
  }
}