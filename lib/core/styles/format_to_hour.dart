// ignore_for_file: use_key_in_widget_constructors

import 'package:intl/intl.dart';

String formatToHour(String time24) {
  final time = DateFormat("HH:mm:ss").parse(time24);
  return DateFormat("hh:mm a").format(time); // مثال: 09:00 PM
}

String formatDate(String date) {
  final parsedDate = DateTime.parse(date); // تحويل من نص إلى DateTime
  return DateFormat('dd MMM, yyyy').format(parsedDate); // النتيجة: 05 Apr, 2025
}
