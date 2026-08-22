import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/streak_badge.dart';

import '../services/storage_service.dart';

class AppController extends ChangeNotifier {
  static const _channel = MethodChannel(AppConstants.blockerMethodChannel);
  final StorageService _storageService = StorageService();

  AppSettings settings = AppSettings(
    defaultPomodoroMinutes: 25,
    defaultAppBlockerEnabled: true,
  );

  List<Project> projects = [];
  List<Task> tasks = [];
  StreakData streakData = StreakData();

  Task? activeTask;
  bool isTimerRunning = false;
  int selectedTabIndex = 0;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppController();

  Future<void> init() async {
    settings = await _storageService.loadSettings();
    projects = await _storageService.loadProjects();
    tasks = await _storageService.loadTasks();
    streakData = await _storageService.loadStreakData();

    recalculateStreak();
    _isInitialized = true;
    notifyListeners();
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void recalculateStreak() {
    final now = DateTime.now();
    final todayKey = _formatDateKey(now);

    final todayPomodoros = tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);

    final dates = List<String>.from(streakData.activeDates);
    if (todayPomodoros >= settings.dailyGoalPomodoros && !dates.contains(todayKey)) {
      dates.add(todayKey);
    }

    dates.sort();
    int current = 0;
    int longest = streakData.longestStreak;

    if (dates.isNotEmpty) {
      final dateObjects = dates.map((d) => DateTime.parse(d)).toList();
      int streak = 1;
      int maxStreak = 1;

      for (int i = 1; i < dateObjects.length; i++) {
        final diff = dateObjects[i].difference(dateObjects[i - 1]).inDays;
        if (diff == 1) {
          streak++;
        } else if (diff > 1) {
          streak = 1;
        }
        if (streak > maxStreak) maxStreak = streak;
      }

      final latest = dateObjects.last;
      final daysFromNow = DateTime(now.year, now.month, now.day).difference(DateTime(latest.year, latest.month, latest.day)).inDays;
      if (daysFromNow <= 1) {
        current = streak;
      } else {
        current = 0;
      }

      if (maxStreak > longest) longest = maxStreak;
    }

    streakData = StreakData(
      currentStreak: current,
      longestStreak: longest,
      activeDates: dates,
    );
    _storageService.saveStreakData(streakData);
  }

  void updateDailyGoal(int newGoal) {
    settings.dailyGoalPomodoros = newGoal;
    saveSettings();
    recalculateStreak();
    notifyListeners();
  }

  Future<void> saveTasks() async {
    await _storageService.saveTasks(tasks);
    recalculateStreak();
  }

  Future<void> saveProjects() async {
    await _storageService.saveProjects(projects);
  }

  Future<void> saveSettings() async {
    await _storageService.saveSettings(settings);
  }

  void setTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    saveSettings();
    recalculateStreak();
    notifyListeners();
  }

  void toggleTaskTimer(Task task) {
    if (activeTask?.id == task.id && isTimerRunning) {
      isTimerRunning = false;
    } else {
      activeTask = task;
      isTimerRunning = true;
      selectedTabIndex = 1;
    }
    notifyListeners();
  }

  void pauseTimer() {
    isTimerRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    isTimerRunning = true;
    notifyListeners();
  }

  void completeTaskDirectly(Task task) {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    if (activeTask?.id == task.id) {
      activeTask = null;
      isTimerRunning = false;
    }
    saveTasks();
    notifyListeners();
  }

  void completeActiveTask() {
    if (activeTask != null) {
      completeTaskDirectly(activeTask!);
    }
  }

  void addNewTask(Task newTask) {
    tasks.add(newTask);
    saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      if (activeTask?.id == updatedTask.id) {
        activeTask = updatedTask;
      }
      saveTasks();
      notifyListeners();
    }
  }

  void addNewProject(Project newProject) {
    projects.add(newProject);
    saveProjects();
    notifyListeners();
  }

  void updateProject(Project updatedProject) {
    final index = projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      projects[index] = updatedProject;
      saveProjects();
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    projects.removeWhere((p) => p.id == projectId);
    for (var task in tasks) {
      if (task.projectId == projectId) {
        task.projectId = '';
      }
    }
    saveProjects();
    saveTasks();
    notifyListeners();
  }

  Future<bool> requestBackgroundUsage() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
      return true;
    } catch (e) {
      debugPrint('Background usage request (Android only): \$e');
      return false;
    }
  }
}
