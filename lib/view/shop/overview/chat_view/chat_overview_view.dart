import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/custom_widget/maps/map_widget.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/location_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/merchant/gallery_list.dart';
import 'package:afandim/view/support_chat/models/Chat.dart';
import 'package:afandim/view/support_chat/models/Conversation.dart';
import 'package:afandim/view/support_chat/utils/map_utils.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatOverViewScreen extends StatefulWidget {
  final Map merchantData;

  ChatOverViewScreen(this.merchantData);

  @override
  _ChatOverViewScreenState createState() => _ChatOverViewScreenState();
}

class _ChatOverViewScreenState extends State<ChatOverViewScreen> {
  final TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  final _prefManager = PrefManager();
  bool isLogin = false;
  String token = '';
  bool isLoading = true;
  List<Chat> chatList = List();
  final picker = ImagePicker();
  File _image;
  String userName = '';
  String userImage = '';
  String country = '';
  String countryId = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final provider = context.read(generalProvider);
    if (provider.apiUrl.contains("tr.efendim.biz")) {
      country = 'Turkey';
      countryId = 'TR';
    } else {
      country = 'Jordan';
      countryId = 'JO';
    }
    isLogin = await _prefManager.contains("token");
    if (isLogin) {
      token = await _prefManager.get('token', '');
      var jsonData = json.decode(await _prefManager.get("user.data", ''));
      userName = jsonData['first_name'] + ' ' + jsonData['last_name'];
      userImage = '';
    } else {
      token = FirebaseFirestore.instance.collection('Users').doc().id;
      userName = 'Guest';
      userImage = '';
    }
    getUserChat();
  }

  _openImagePicker() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 500,
        maxHeight: 500);
    if (mounted)
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          uploadMessageImage(_image, token, widget.merchantData['merchant_id'],
              () {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut);
          });
        } else {
          print('No image selected.');
        }
      });
  }

  uploadMessageImage(File image, String currentUserId, String receiverId,
      Function() onImageSent) async {
    if (image != null) {
      /// TODO  : HERE UPDATE
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child("$currentUserId/chat").putFile(image);
      if (snapshot.state == TaskState.error) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        sendStudentMessage(currentUserId, receiverId, downloadUrl, 'image',
            (isSend, error) {
          onImageSent();
        });
      }
    }
  }

  getUserChat() async {
    FirebaseFirestore.instance
        .collection(country)
        .doc(countryId)
        .collection('Users')
        .doc(token)
        .collection('Conversation')
        .doc(widget.merchantData['merchant_id'])
        .collection('Chat')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (event != null && event.docs.length > 0) {
        event.docChanges.forEach((documentChange) {
          if (documentChange.type == DocumentChangeType.added) {
            chatList.add(Chat.fromMap(documentChange.doc.data()));
          }
        });
        Future.delayed(Duration(seconds: 1), () {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
        });
      }
    });
  }

  sendStudentMessage(
    String currentUserId,
    String receiverId,
    String message,
    String messageType,
    Function(bool isSend, String error) onMessageSent,
  ) async {
    try {
      if (chatList.length == 0) {
        Conversation conversation = Conversation(
            receiverId,
            FieldValue.serverTimestamp(),
            '',
            widget.merchantData['merchant_name'],
            null);
        await FirebaseFirestore.instance
            .collection(country)
            .doc(countryId)
            .collection('Users')
            .doc(currentUserId)
            .collection('Conversation')
            .doc(receiverId)
            .set(conversation.toMap());
        Conversation toConversation = Conversation(
            currentUserId, FieldValue.serverTimestamp(), '', userName, null);
        await FirebaseFirestore.instance
            .collection(country)
            .doc(countryId)
            .collection('Merchants')
            .doc(receiverId)
            .collection('Conversation')
            .doc(currentUserId)
            .set(toConversation.toMap());
      }
      String chatId = FirebaseFirestore.instance
          .collection(country)
          .doc(countryId)
          .collection('Users')
          .doc(currentUserId)
          .collection('Conversation')
          .doc(receiverId)
          .collection('Chat')
          .doc()
          .id;
      Chat chat = Chat(chatId, message, messageType, currentUserId, userName,
          userImage, true, FieldValue.serverTimestamp());
      await FirebaseFirestore.instance
          .collection(country)
          .doc(countryId)
          .collection('Users')
          .doc(currentUserId)
          .collection('Conversation')
          .doc(receiverId)
          .collection('Chat')
          .doc(chatId)
          .set(chat.toMap());
      await FirebaseFirestore.instance
          .collection(country)
          .doc(countryId)
          .collection('Merchants')
          .doc(receiverId)
          .collection('Conversation')
          .doc(currentUserId)
          .collection('Chat')
          .doc(chatId)
          .set(chat.toMap());
      Map<String, dynamic> hashMap = Map();
      hashMap['lastMessage'] = chat.message;
      hashMap['lastMessageTime'] = chat.date;
      await FirebaseFirestore.instance
          .collection(country)
          .doc(countryId)
          .collection('Merchants')
          .doc(receiverId)
          .collection('Conversation')
          .doc(currentUserId)
          .update(hashMap);
      sendBlogNotification();
      onMessageSent(true, '');
    } catch (e) {
      onMessageSent(false, 'Some error occurred.');
    }
  }

  sendMessage() async {
    String message = messageController.text.toString();
    if (message.isNotEmpty) {
      messageController.text = '';
      await sendStudentMessage(
          token, widget.merchantData['merchant_id'], message, 'text',
          (isSuccess, error) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchantData['restaurant_name']),
      ),
      body: SafeArea(
        child: Column(
          children: [
            isLoading
                ? Expanded(
                    child: Center(
                      child: LoadingWidget(),

                      // child: SpinKitThreeBounce(
                      //   size: 82.0,
                      //   color: Theme.of(context).primaryColor,
                      // ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, index) {
                        return chatList[index].messageSenderId == token
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, left: 15, right: 15),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _getSenderChatData(index),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, left: 15, right: 15),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _getReceiverChatData(index),
                                    ],
                                  ),
                                ),
                              );
                      },
                      itemCount: chatList.length,
                    ),
                  )),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _openImagePicker();
                    },
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getCurrentLocation().then((value) {
                        Position data = value;
                        String location = '${data.latitude},${data.longitude}';
                        sendStudentMessage(
                            token,
                            widget.merchantData['merchant_id'],
                            location,
                            'location',
                            (isSend, error) {});
                      });
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.only(
                              left: 12, right: 12, top: 10, bottom: 10),
                          fillColor: Color(0xFFFFFFFF),
                          hintText: lang.api("Add message...")),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                    onTap: () {
                      sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getReceiverChatData(int index) {
    if (chatList[index].messageType == 'text' ||
        chatList[index].messageType == 'location') {
      return GestureDetector(
        onTap: () {
          if (chatList[index].messageType == 'location') {
            Map<String, String> location = Map();
            final split = chatList[index].message.split(',');
            location["latitude"] = split[0];
            location["longitude"] = split[1];
            MapUtils.openMap(double.parse(split[0]), double.parse(split[1]));
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              child: Image.network(
                'https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/default-avatar.png',
                width: 50,
                height: 50,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Bubble(
                  margin: BubbleEdges.only(top: 10),
                  alignment: Alignment.topRight,
                  nip: BubbleNip.leftTop,
                  color: Theme.of(context).accentColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatList[index].userName,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      chatList[index].messageType == 'location'
                          ? Container(
                              height: 160,
                              width: 200,
                              child: IgnorePointer(
                                ignoring: true,
                                child: MapWidget(
                                  key: UniqueKey(),
                                  currentLocation: {
                                    "latitude":
                                        chatList[index].message.split(',')[0],
                                    "longitude":
                                        chatList[index].message.split(',')[1]
                                  },
                                ),
                              ),
                            )
                          : Text(
                              chatList[index].message,
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      List list = [];
      list.add(chatList[index].message);
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return GalleryList(
                image: chatList[index].message,
                list: list,
              );
            }),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Image.network(
                'https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/default-avatar.png',
                width: 50,
                height: 50,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chatList[index].userName),
                SizedBox(
                  height: 5,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: chatList[index].message,
                    fit: BoxFit.fill,
                    height: 130,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  _getSenderChatData(int index) {
    if (chatList[index].messageType == 'text' ||
        chatList[index].messageType == 'location')
      return GestureDetector(
        onTap: () {
          if (chatList[index].messageType == 'location') {
            Map<String, String> location = Map();
            final split = chatList[index].message.split(',');
            location["latitude"] = split[0];
            location["longitude"] = split[1];
            MapUtils.openMap(double.parse(split[0]), double.parse(split[1]));
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Bubble(
                  margin: BubbleEdges.only(top: 10),
                  alignment:
                      lang.isRtl() ? Alignment.topLeft : Alignment.topRight,
                  nip: lang.isRtl() ? BubbleNip.leftTop : BubbleNip.rightTop,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chatList[index].userName,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      chatList[index].messageType == 'location'
                          ? Container(
                              height: 160,
                              width: 200,
                              child: IgnorePointer(
                                ignoring: true,
                                child: MapWidget(
                                  currentLocation: {
                                    "latitude":
                                        chatList[index].message.split(',')[0],
                                    "longitude":
                                        chatList[index].message.split(',')[1]
                                  },
                                ),
                              ),
                            )
                          : Text(
                              chatList[index].message,
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            CircleAvatar(
              child: Image.network(
                'https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/default-avatar.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      );
    else {
      List list = List();
      list.add(chatList[index].message);
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return GalleryList(
                image: chatList[index].message,
                list: list,
              );
            }),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chatList[index].userName),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 130,
                  width: 130,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: chatList[index].message,
                      fit: BoxFit.fill,
                      height: 130,
                      placeholder: (context, url) =>
                          new CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            CircleAvatar(
              child: Image.network(
                'https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/default-avatar.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<http.Response> sendBlogNotification() {
    HashMap<String, dynamic> hashMap = HashMap();
    hashMap['app_id'] = '398609d5-3109-4d6d-8507-e7dcdd8f7339';
    HashMap<String, String> contentHashMap = HashMap();
    contentHashMap['en'] = '$userName sent a new message';
    hashMap['contents'] = contentHashMap;
    HashMap<String, String> headingHashMap = HashMap();
    headingHashMap['en'] = 'Efendim';
    hashMap['headings'] = headingHashMap;
    hashMap['include_external_user_ids'] = [widget.merchantData['merchant_id']];
    return http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Basic OWUwZTRlNjMtZDkwYS00OGFlLWEyMDAtYTAxYWQ2MWU1NDQ2'
      },
      body: jsonEncode(hashMap),
    );
  }
}
