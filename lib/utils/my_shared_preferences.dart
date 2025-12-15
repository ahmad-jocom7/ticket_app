import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/auth/login_model.dart';

class MySharedPreferences {
  static late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void clearProfile() {
    isLogin = false;
    username = '';
    clearUserData();
  }

  Future<void> saveUserData(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _sharedPreferences.setString(keyUserData, jsonString);
  }

  UserModel? getUserData() {
    final jsonString = _sharedPreferences.getString(keyUserData);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return UserModel.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _sharedPreferences.remove(keyUserData);
  }

  bool get isLogin => _sharedPreferences.getBool(keyIsLogin) ?? false;

  set isLogin(bool value) {
    _sharedPreferences.setBool(keyIsLogin, value);
  }

  String get username => _sharedPreferences.getString(keyUserName) ?? "";

  set username(String value) {
    _sharedPreferences.setString(keyUserName, value);
  }

  String get deviceId => _sharedPreferences.getString(keyDeviceId) ?? "";

  set deviceId(String value) {
    _sharedPreferences.setString(keyDeviceId, value);
  }

  String get deviceModel => _sharedPreferences.getString(keyDeviceModel) ?? "";

  set deviceModel(String value) {
    _sharedPreferences.setString(keyDeviceModel, value);
  }

  String get deviceVersion => _sharedPreferences.getString(keyDeviceVersion) ?? "";

  set deviceVersion(String value) {
    _sharedPreferences.setString(keyDeviceVersion, value);
  }

  int get bookId => _sharedPreferences.getInt(keyBookId) ?? 0;

  set bookId(int value) {
    _sharedPreferences.setInt(keyBookId, value);
  }
}

final mySharedPreferences = MySharedPreferences();

const String keyUserData = "key_user_data";
const String keyIsLogin = "key_is_login";
const String keyUserName = "key_username";
const String keyBookId = "key_book_id";
const String keyDeviceId = "key_device_id";
const String keyDeviceModel = "key_device_model";
const String keyDeviceVersion = "key_device_version";
