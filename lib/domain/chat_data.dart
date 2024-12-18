class PrivateMessageData {
  PrivateMessageData({
    required this.userId, required this.content,
    required this.sentAt, required this. isRead,
    required this.imgData, required this.fileData,
    required this.fileName,
  });

  final int userId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String imgData;
  final String fileData;
  final String fileName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory PrivateMessageData.fromJson(dynamic json) {
    return PrivateMessageData(
      userId: json['user_id'] as int,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool,
      imgData: json['image_data'] as String,
      fileData: json['file_data'] as String,
      fileName: json['file_name'] as String,
     );
  }
}

class GroupChatRoomData {
  GroupChatRoomData({
    required this.id, required this.name, required this.imgData, required this.createdAt,
  });

  final int id;
  final String name;
  final String imgData;
  final DateTime createdAt;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupChatRoomData.fromJson(dynamic json) {
    return GroupChatRoomData(
      id: json['id'] as int,
      name: json['name'] as String,
      imgData: json['image'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class GroupMessageData {
  GroupMessageData({
    required this.userId, required this.content,
    required this.sentAt, required this. isRead,
    required this.imgData, required this.fileData,
    required this.fileName,
  });

  final int userId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String imgData;
  final String fileData;
  final String fileName;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory GroupMessageData.fromJson(dynamic json) {
    return GroupMessageData(
      userId: json['user_id'] as int,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool,
      imgData: json['image_data'] as String,
      fileData: json['file_data'] as String,
      fileName: json['file_name'] as String,
    );
  }
}