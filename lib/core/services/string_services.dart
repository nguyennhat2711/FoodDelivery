import 'package:intl/intl.dart';

class StringService {
  static String getReviewValue(double value) {
    if (value == 0) return '0.0';
    final formatter = new NumberFormat("#.#");
    return formatter.format(value);
  }
}