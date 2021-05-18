import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalProvider =
    ChangeNotifierProvider<GeneralProvider>((ref) => GeneralProvider());

class GeneralProvider with ChangeNotifier {
  String _apiUrl;
  String _apiBaseUrl;
  String _apiKey;
  Map _currentCountry;
  List _addressList;

  List get addressList => _addressList;

  set addressList(List value) {
    _addressList = value;
    notifyListeners();
  }

  String get apiKey => _apiKey;

  set apiKey(String value) {
    _apiKey = value;
    notifyListeners();
  }

  String get apiBaseUrl => _apiBaseUrl;

  set apiBaseUrl(String value) {
    _apiBaseUrl = value;
    notifyListeners();
  }

  String get apiUrl => _apiUrl;

  set apiUrl(String value) {
    _apiUrl = value;
    notifyListeners();
  }

  Map get currentCountry => _currentCountry;

  set currentCountry(Map value) {
    _currentCountry = value;
    notifyListeners();
  }
}
