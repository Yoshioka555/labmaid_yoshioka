import 'package:labmaidfastapi/domain/user_data.dart';
import 'package:flutter/material.dart';
import 'package:labmaidfastapi/user/edit_user_model.dart';
import 'package:provider/provider.dart';
import '../header_footer_drawer/footer.dart';
import '../pick_export/pick_image_export.dart';
import 'dart:typed_data';
import 'dart:convert';

class EditMyPage extends StatefulWidget {
  final UserData myData;
  const EditMyPage({Key? key, required this.myData}) : super(key:key);
  @override
  _EditMyPageState createState() => _EditMyPageState();
}

class _EditMyPageState extends State<EditMyPage> {

  late TextEditingController _nameController;
  late TextEditingController _groupController;
  late TextEditingController _gradeController;
  Uint8List? userImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.myData.name);
    _groupController = TextEditingController(text: widget.myData.group);
    _gradeController = TextEditingController(text: widget.myData.grade);
    userImage = base64Decode(widget.myData.imgData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditUserModel>(
      create: (_) => EditUserModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightGreen.shade700,
          title: const Text('アカウント情報変更',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white,
          ),
        ),
        body: Consumer<EditUserModel>(builder: (context, model, child){
          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus(); // フォーカスを解除
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final imageData = await PickImage().pickImage();
                              setState(() {
                                userImage = imageData!;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              backgroundImage: userImage != null ? Image.memory(
                                userImage!,
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
                          ),
                        ),
                        const SizedBox(height: 10,),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 850),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: const Divider(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 850,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: '名前(苗字のみ)',
                                icon: Icon(Icons.person),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Text(
                          '選択した班：${_groupController.text}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Web班',
                                      groupValue: _groupController.text,
                                      onChanged: (text) {
                                        setState(() {
                                          _groupController.text = text!;
                                        });
                                      },
                                    ),
                                    const Text('Web班'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Grid班',
                                      groupValue: _groupController.text,
                                      onChanged: (text) {
                                        setState(() {
                                          _groupController.text = text!;
                                        });
                                      },
                                    ),
                                    const Text('Grid班'),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: 'Network班',
                                      groupValue: _groupController.text,
                                      onChanged: (text) {
                                        setState(() {
                                          _groupController.text = text!;
                                        });
                                      },
                                    ),
                                    const Text('Network班'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      activeColor: Colors.blueAccent,
                                      value: '教員',
                                      groupValue: _groupController.text,
                                      onChanged: (text) {
                                        setState(() {
                                          _groupController.text = text!;
                                        });
                                      },
                                    ),
                                    const Text('教員'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          '選択した学年：${_gradeController.text}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        DropdownButton(
                            value: _gradeController.text,
                            items: const [
                              DropdownMenuItem(
                                value: 'B4',
                                child: Text('B4'),
                              ),
                              DropdownMenuItem(
                                value: 'M1',
                                child: Text('M1'),
                              ),
                              DropdownMenuItem(
                                value: 'M2',
                                child: Text('M2'),
                              ),
                              DropdownMenuItem(
                                value: 'D1',
                                child: Text('D1'),
                              ),
                              DropdownMenuItem(
                                value: 'D2',
                                child: Text('D2'),
                              ),
                              DropdownMenuItem(
                                value: 'D3',
                                child: Text('D3'),
                              ),
                              DropdownMenuItem(
                                value: '教授',
                                child: Text('教授'),
                              ),
                            ],
                            onChanged: (text) {
                              setState(() {
                                _gradeController.text = text!;
                              });
                            }
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  model.startLoading();
                                  if (userImage != []) {
                                    await model.updateImage(userImage, widget.myData.id);
                                  }
                                  await model.update(_nameController.text, _groupController.text, _gradeController.text, widget.myData.id);

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Footer(pageNumber: 5)),
                                        (route) => false,
                                  );
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('ユーザデータの更新ができました。'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } catch (error) {
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(error.toString()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } finally {
                                  model.endLoading();
                                }
                              },
                              child: const Text('変更する'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (model.isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}