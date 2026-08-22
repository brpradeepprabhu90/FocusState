import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/project.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'flowstate_tasks';
  static const String _projectsKey = 'flowstate_projects';
  static const String _settingsKey = 'flowstate_settings';
  static const String _blockedAppsKey = 'flowstate_blocked_app_states';
  static const String _themeModeKey = 'flowstate_theme_mode';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonString);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Task.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, jsonString);
  }

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_projectsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Project.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, jsonString);
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AppSettings.fromJson(jsonMap);
    }
    return AppSettings();
  }

  Future<void> saveBlockedAppStates(Map<String, bool> states) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(states);
    await prefs.setString(_blockedAppsKey, jsonString);
  }

  Future<Map<String, bool>> loadBlockedAppStates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_blockedAppsKey);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {};
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_themeModeKey);
    if (name != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ThemeMode.dark,
      );
    }
    return ThemeMode.dark;
  }
}
