import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../domain/memo_data.dart';
import '../door_status/door_status_appbar.dart';
import '../gemini/gemini_chat_page.dart';
import '../geo_location/location_member_index.dart';
import '../header_footer_drawer/drawer.dart';
import 'minutes_add_page.dart';
import 'minutes_index_model.dart';
import 'minutes_show_page.dart';

class MemoListPage extends StatelessWidget {
  const MemoListPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<GroupColor> groupColorList = [GroupColor('Web班', Colors.cyanAccent), GroupColor('Net班', Colors.yellow), GroupColor('機械学習班', Colors.lightGreenAccent), GroupColor('時間拡大班', Colors.teal), GroupColor('All', Colors.purpleAccent), ];

    return ChangeNotifierProvider<MemoListModel>(
      create: (_) => MemoListModel()..fetchMemoList(),
      child: Scaffold(
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
          backgroundColor: Colors.blue.shade800,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: false,
          elevation: 0.0,
          title: const DoorStatusAppbar(),
        ),
        drawer: const UserDrawer(),
        body: Consumer<MemoListModel>(builder: (context, model, child) {

          List<MemoData> memoList (String team, String kinds) {
            // teamとkindsが一致するMemoDataオブジェクトをフィルタリング
            List<MemoData> filteredMemoList = model.memoList.where((memo) => memo.team == team && memo.kinds == kinds).toList();

            // createdAtで降順に並び替え（新しい日付が先になるように）
            filteredMemoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return filteredMemoList;
          }

          // ListView(children: widgets)
          return ListView.builder(
            itemCount: groupColorList.length,
            itemBuilder: (BuildContext context, int index) =>
                _buildList(groupColorList[index], memoList(groupColorList[index].group, 'ミーティング'), memoList(groupColorList[index].group, 'その他'), context),
          );
        }),

        floatingActionButton: Consumer<MemoListModel>(builder: (context, model, child) {

          return FloatingActionButton(
            onPressed: () async {
              final bool? added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemoPage(myData: model.myData!),
                  fullscreenDialog: true,
                ),
              );

              if (added != null && added) {
                const snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('議事録を追加しました'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              model.fetchMemoList();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        }
        ),
      ),
    );
  }

  Widget _buildList(GroupColor list, List<MemoData> memoList1, List<MemoData> memoList2, BuildContext context) {
    return ExpansionTile(
      collapsedBackgroundColor: list.color,
      backgroundColor: list.color,
      textColor: Colors.black,
      title: Text(
        list.group,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      children: [
        ListTile(
          title: TextButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => MemoListShow(memoList: memoList1),
                  fullscreenDialog: true,
                ),
              );
            },
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
            child: const Text('ミーティング',
              style: TextStyle(
                  color: Colors.black
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        ListTile(
          title: TextButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => MemoListShow(memoList: memoList2),
                  fullscreenDialog: true,
                ),
              );
            },
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
            child: const Text('その他',
              style: TextStyle(
                  color: Colors.black
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }
}
