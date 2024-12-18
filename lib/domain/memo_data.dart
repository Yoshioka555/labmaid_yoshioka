import 'dart:ui';

class MemoData {
  MemoData({
    required this.id, required this.title, required this.createdAt,
    required this.team, required this.mainText, required this.kinds,
    required this.userId, required this.userName,
  });

  final int id;
  String title;
  final DateTime createdAt;
  String team;
  String mainText;
  String kinds;
  final int userId;
  String userName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory MemoData.fromJson(dynamic json) {
    return MemoData(
      id: json['id'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      team: json['team'] as String,
      mainText: json['main_text'] as String,
      kinds: json['kinds'] as String,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
    );
  }
}

class GroupColor {
  GroupColor(this.group, this.color);
  String group;
  Color color;
}
