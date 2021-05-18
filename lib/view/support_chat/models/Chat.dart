import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String messageId;
  String message;
  String messageType;
  String messageSenderId;
  String userName;
  String userImage;
  bool isMessageSent;
  FieldValue date;

  Chat(this.messageId, this.message, this.messageType, this.messageSenderId,
      this.userName, this.userImage, this.isMessageSent, this.date);

  Chat.fromMap(Map<dynamic, dynamic> map) {
    this.messageId = map['messageId'] ?? '';
    this.message = map['message'] ?? '';
    this.messageType = map['messageType'] ?? '';
    this.messageSenderId = map['messageSenderId'] ?? '';
    this.userName = map['userName'] ?? '';
    this.userImage = map['userImage'] ?? '';
    this.isMessageSent = map['isMessageSent'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'message': message,
      'messageType': messageType,
      'messageSenderId': messageSenderId,
      'userName': userName,
      'userImage': userImage,
      'isMessageSent': isMessageSent,
      'date': date,
    };
  }
}
