import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  String? getString(String key) {
    return _preferences!.getString(key);
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  // Object operations
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _preferences!.setString(key, json.encode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _preferences!.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // List operations
  Future<bool> setList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  List<String>? getList(String key) {
    return _preferences!.getStringList(key);
  }

  Future<bool> setObjectList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final List<String> jsonStringList =
        value.map((item) => json.encode(item)).toList();
    return await _preferences!.setStringList(key, jsonStringList);
  }

  List<Map<String, dynamic>>? getObjectList(String key) {
    final List<String>? jsonStringList = _preferences!.getStringList(key);
    if (jsonStringList == null) return null;
    return jsonStringList
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
  }

  // Remove operations
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  Future<bool> clear() async {
    return await _preferences!.clear();
  }

  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}
