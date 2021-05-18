import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatOverViewViewModel = ChangeNotifierProvider<ChatOverViewViewModel>(
    (ref) => ChatOverViewViewModel());

class ChatOverViewViewModel extends ChangeNotifier {}
