// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

class FileConverter implements JsonConverter<File, File> {
  const FileConverter();

  @override
  File fromJson(File json) {
    return json;
  }

  @override
  File toJson(File object) {
    return object;
  }
}
