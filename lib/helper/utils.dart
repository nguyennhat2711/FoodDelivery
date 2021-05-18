import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'global_translations.dart';

String formatPhoneLabel(String phone){
  String newPhone = "";
  for(int i = 0 ; i < phone.length; i++){
    if(i == 3 || i == 5 || i == 8){
      newPhone += " ";
    }
    newPhone += phone[i];
  }
  return newPhone;
}
double customRound(val, int places) {
  double mod = pow(10.0, places);
  return ((val * 1.0 * mod).round().toDouble() / mod);
}
String formatCardNumber(String cardNumber, [bool hideMiddle = true]){
  if(hideMiddle){
    cardNumber = cardNumber.replaceRange(4, cardNumber.length - 4, "XXXXXXXX");
  }
  String newCardNumber = "";
  for(int i = 0 ; i < cardNumber.length; i++){
    if(i%4 == 0){
      newCardNumber += " ";
    }
    newCardNumber += cardNumber[i];
  }
  return newCardNumber;
}
String getFirstChars(String name){
  String chars = "";
  List<String> names = name.split(" ");
  names.forEach((String name){
    if(chars.length < 2 && name.length > 0){
      chars += name[0].toUpperCase();
    }
  });
  return chars;
}
String getFileBase64(File image) {
  if(image != null) {
    List<int> bytes = image.readAsBytesSync();
    String base64Image = base64Encode(bytes);
    return base64Image;
  }
  return null;
}

List<Map<String, dynamic>> getListFromMap(Map map, [bool translated = true]) {
  List<Map<String, dynamic>> temp = [];
  map.keys.toList().forEach((key) {
    temp.add({"name": translated? lang.api(key): map[key], "id": key});
  });

  return temp;
}
Future<String> getJsonFile(String fileName) async {
  return await rootBundle.loadString(fileName);
}
bool isArabic(String text){
  final int maxBits = 128;
  List<int> unicodeSymbols = text.codeUnits.where((ch) => ch > maxBits ).toList();
//  print("Text is arabic: ${unicodeSymbols.length > 0}");
  return unicodeSymbols.length > 0;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}

showToast(String message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[200],
      textColor: Colors.black54,
      fontSize: 16.0
  );
}

String validateEmail(String value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Email is Required";
  } else if(!regExp.hasMatch(value)){
    return "Invalid Email";
  }else {
    return null;
  }
}


String validateName(String value) {

  if (value.length == 0 ) {
    return "First name is required";
  }
  return null;
}
String validateUserNAme(String value) {

  if (value.length == 0 ) {
    return "User name is required";
  }
  return null;
}
String validateTransportDesc(String value) {

  if (value.length == 0 ) {
    return "Transport Description is required";
  }
  return null;
}
String validateLicence(String value) {

  if (value.length == 0 ) {
    return "License Plate is required";
  }
  return null;
}

String validateColor(String value) {

  if (value.length == 0 ) {
    return "Color is required";
  }
  return null;
}
String validateLastName(String value) {

  if (value.length == 0 ) {
    return "Last name is required";
  }
  return null;
}

String validatePassword(String value) {

  if (value.length == 0 ) {
    return "Password is required";
  }else if(value.length < 6){
    return "Passwords must use at least six characters lowercase letters, uppercase letters, numbers, and symbols";
  }else if(!isPasswordCompliant(value)){
    return "Passwords must use at least six characters lowercase letters, uppercase letters, numbers, and symbols";
  }
  return null;
}

bool isPasswordCompliant(String password, [int minLength = 6]) {
  if (password == null || password.isEmpty) {
    return false;
  }

  bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
  bool hasDigits = password.contains(new RegExp(r'[0-9]'));
  bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
  bool hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool hasMinLength = password.length > minLength;

  return hasDigits & hasUppercase & hasLowercase & hasSpecialCharacters & hasMinLength;
}

String validateMobile(String value) {
  String patttern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Mobile is required";
  } else if(value.length < 6){
    return "Invalid mobile number ";
  }else if (!regExp.hasMatch(value)) {
    return "Mobile number must be in digits";
  }
  return null;
}


