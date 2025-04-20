import 'package:intl/intl.dart';

String formatTime(String time24) {
  final time = DateFormat("HH:mm:ss").parse(time24);
  return DateFormat("h a").format(time); // مثال: "2 PM"
}
