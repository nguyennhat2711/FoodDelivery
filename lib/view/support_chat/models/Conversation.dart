import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  String conversationId;
  FieldValue date;
  String lastMessage;
  String userName;
  FieldValue lastMessageTime;

  Conversation(this.conversationId,this.date,this.lastMessage,this.userName,this.lastMessageTime);

  Conversation.fromJson(Map<dynamic,dynamic> map){
    this.conversationId = map['conversationId'] ?? '';
    this.lastMessage = map['lastMessage'] ?? '';
    this.userName = map['userName'] ?? '';
  }

  Map<String,dynamic> toMap(){
    return {
      'conversationId': conversationId,
      'date': date,
      'lastMessage': lastMessage,
      'userName': userName,
      'lastMessageTime': lastMessageTime
    };
  }
}