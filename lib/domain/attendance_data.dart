class AttendanceData {
  AttendanceData({
    required this.id, required this.title, required this.start, required this.end,
    required this.description, required this.mailSend, required this.undecided, required this.userId, required this.userName,
  });
  final int id;
  String title;
  DateTime start;
  DateTime end;
  String description;
  bool mailSend;
  bool undecided;
  final int userId;
  final String userName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory AttendanceData.fromJson(dynamic json) {
    return AttendanceData(
      id: json['id'] as int,
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      description: json['description'] as String,
      mailSend: json['mail_send'] as bool,
      undecided: json['undecided'] as bool,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
    );
  }
}