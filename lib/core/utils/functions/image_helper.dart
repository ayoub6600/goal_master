import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class FilesHelper {
  static Future<String?> getBase64FromFile(XFile? file) async {
    // Convert the picked image file to Base64
    if (file == null) return null;
    final data = await file.readAsBytes();
    return base64Encode(data);
  }

  static bool isSvg(String imageLink) {
    String? extention = imageLink.split('.').last;
    if (extention.contains('svg')) {
      return true;
    } else {
      return false;
    }
  }
}
