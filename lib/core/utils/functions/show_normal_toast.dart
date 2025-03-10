import 'dart:ui';

import 'package:oktoast/oktoast.dart';

void showNormalToast(String text) {
  showToast(
    text,
    position: ToastPosition.bottom,
    textDirection: TextDirection.rtl,
  );
}
