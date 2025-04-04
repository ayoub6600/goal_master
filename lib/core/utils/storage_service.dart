import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goal_master/core/utils/functions/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../manager/user_info_cubit/user_info_cubit.dart';

late SharedPreferences prefs;

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await _initToken();
  }

  static Future<void> _initToken() async {
    String? t = await AuthManager.getToken();
    //   UserInfoCubit.setToken(t);
  }

  /// Save a value in SharedPreferences
  static Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
  }

  /// Get a value from SharedPreferences
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// Remove a value from SharedPreferences
  static Future<void> removeString(String key) async {
    await prefs.remove(key);
  }

  /// Save a value securely using FlutterSecureStorage
  static Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get a secure value from FlutterSecureStorage
  static Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Remove a value from FlutterSecureStorage
  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
}
