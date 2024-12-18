class EventData {
  EventData({
    required this.id, required this.title, required this.start, required this.end,
    required this.unit, required this.description, required this.mailSend, required this.userId, required this.userName,
});
  final int id;
  String title;
  DateTime start;
  DateTime end;
  String unit;
  String description;
  bool mailSend;
  final int userId;
  final String userName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory EventData.fromJson(dynamic json) {
    return EventData(
        id: json['id'] as int,
        title: json['title'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        unit: json['unit'] as String,
        description: json['description'] as String,
        mailSend: json['mail_send'] as bool,
        userId: json['user_id'] as int,
        userName: json['user_name'] as String,
    );
  }
}

