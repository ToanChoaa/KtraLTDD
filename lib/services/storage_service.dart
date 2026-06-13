// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _gameStateKey = 'saved_game_state';

  /// Lưu trạng thái ván cờ
  static Future<void> saveGameState(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.toJson());
      await prefs.setString(_gameStateKey, json);
    } catch (e) {
      // Bỏ qua lỗi lưu trữ
    }
  }

  /// Tải trạng thái ván cờ đã lưu
  static Future<GameState?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_gameStateKey);
      if (json == null) return null;
      final map = jsonDecode(json) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Xóa trạng thái đã lưu
  static Future<void> clearGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gameStateKey);
    } catch (e) {
      // Bỏ qua lỗi
    }
  }
}
