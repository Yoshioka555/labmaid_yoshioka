class UserAttendanceData {
  UserAttendanceData({
    required this.id, required this.group, required this.name, required this.status,
  });

  final int id;
  final String group;
  final String name;
  String status;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory UserAttendanceData.fromJson(dynamic json) {
    return UserAttendanceData(
      id: json['id'] as int,
      name: json['name'] as String,
      group: json['group'] as String,
      status: json['status'] as String,
    );
  }
}

class UserData {
  UserData({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imgData, required this.firebaseUserId,
    required this.fileName, required this.location, required this.flag,
  });

  final int id;
  String email;
  String group;
  String grade;
  String name;
  String status;
  String imgData;
  final String firebaseUserId;
  String fileName;
  String location;
  bool flag;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory UserData.fromJson(dynamic json) {
    return UserData(
      id: json['id'] as int,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imgData: json['bytes_data'] as String,
      firebaseUserId: json['firebase_user_id'] as String,
      fileName: json['file_name'] as String,
      location: json['now_location'] as String,
      flag: json['location_flag'] as bool,
    );
  }

}

class GroupChatMember {
  GroupChatMember({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imgData, required this.firebaseUserId,
    required this.fileName, required this.join,
  });

  final int id;
  final String email;
  final String group;
  final String grade;
  final String name;
  final String status;
  final String imgData;
  final String firebaseUserId;
  final String fileName;
  bool join;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatMember.fromJson(dynamic json) {
    return GroupChatMember(
      id: json['id'] as int,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imgData: json['bytes_data'] as String,
      firebaseUserId: json['firebase_user_id'] as String,
      fileName: json['file_name'] as String,
      join: true,
    );
  }

}

class GroupChatUserData {
  GroupChatUserData({
    required this.id, required this.email, required this.group, required this.grade,
    required this.name, required this.status, required this.imgData, required this.firebaseUserId,
    required this.fileName,  required this.joinedDate, required this.leaveDate, required this.join,
  });

  final int id;
  final String email;
  final String group;
  final String grade;
  final String name;
  final String status;
  final String imgData;
  final String firebaseUserId;
  final String fileName;
  final DateTime? joinedDate;
  final DateTime? leaveDate;
  final bool join;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatUserData.fromJson(dynamic json) {
    return GroupChatUserData(
      id: json['id'] as int,
      email: json['email'] as String,
      group: json['group'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imgData: json['bytes_data'] as String,
      firebaseUserId: json['firebase_user_id'] as String,
      fileName: json['file_name'] as String,
      joinedDate: json['joined_date'] != null ? DateTime.parse(json['joined_date'] as String) : null,  // nullの場合はnullを返す
      leaveDate: json['leave_date'] != null
          ? DateTime.parse(json['leave_date'] as String)
          : null,  // nullの場合はnullを返す
      join: json['join'] as bool,
    );
  }

}
