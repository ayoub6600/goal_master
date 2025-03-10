import 'dart:io';

import 'package:goal_master/core/extensions/to_snake_case.dart';
import 'package:goal_master/utils/form_data_helper.dart';

class AppFormParser {
  final String _indent;
  final Map<String, dynamic> _obj;
  const AppFormParser(this._indent, this._obj);

  Future<FormDataHelper> generate() async {
    FormDataHelper helper = FormDataHelper();
    for (var entry in _obj.entries) {
      var value = entry.value;
      var key = _keyGenerator(entry.key);
      if (value is File) {
        await helper.addFile(value, fileKey: key);
      } else if (value is List<File>) {
        var obj = _addFilesList(files: value, key: key);
        for (var entry in obj.entries) {
          await helper.addFile(entry.value, fileKey: entry.key);
        }
      } else {
        helper.addEntry(key, value);
      }
    }
    return helper;
  }

  String _keyGenerator(String key) {
    return '$_indent[${key.toSnakeCase()}]';
  }

  Map<String, dynamic> _addFilesList({
    required List<File> files,
    required String key,
  }) {
    Map<String, dynamic> obj = {};
    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      obj['$key[$i]'] = file;
    }
    return obj;
  }
}
