import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/project.dart';
import '../models/task.dart';

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

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveTasks() async {
    await _storageService.saveTasks(tasks);
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
