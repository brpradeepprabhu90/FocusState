import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/project.dart';
import '../models/task.dart';

class AppController extends ChangeNotifier {
  static const _channel = MethodChannel(AppConstants.blockerMethodChannel);

  AppSettings settings = AppSettings(
    defaultPomodoroMinutes: 25,
    defaultAppBlockerEnabled: true,
  );

  final List<Project> projects = [
    Project(id: 'p1', name: 'General Tasks', color: AppConstants.primaryIndigo),
    Project(id: 'p2', name: 'Flutter Dev', color: AppConstants.accentEmerald),
    Project(id: 'p3', name: 'UI/UX Design', color: AppConstants.warningAmber),
  ];

  late List<Task> tasks;

  Task? activeTask;
  bool isTimerRunning = false;
  int selectedTabIndex = 0;

  AppController() {
    final now = DateTime.now();
    tasks = [
      Task(
        id: '1',
        projectId: 'p2',
        title: 'Write Flutter App Architecture',
        durationMinutes: 25,
        reminderTime: '15:00',
        repeatFrequency: 'Daily',
        enableNotification: true,
      ),
      Task(
        id: '2',
        projectId: 'p3',
        title: 'Design Pomodoro Flow Timer',
        durationMinutes: 45,
        reminderTime: '16:30',
        repeatFrequency: 'Weekly',
        enableNotification: true,
      ),
      Task(
        id: '3',
        projectId: 'p1',
        title: 'Setup Environment & Tools',
        durationMinutes: 30,
        isCompleted: true,
        completedAt: now,
        timeSpentSeconds: 1800,
      ),
      Task(
        id: '4',
        projectId: 'p2',
        title: 'Learn Dart Fundamentals',
        durationMinutes: 60,
        isCompleted: true,
        completedAt: DateTime(now.year, now.month, now.day - 2),
        timeSpentSeconds: 3600,
      ),
      Task(
        id: '5',
        projectId: 'p3',
        title: 'User Interface Wireframing',
        durationMinutes: 40,
        isCompleted: true,
        completedAt: DateTime(now.year, now.month - 1, 10),
        timeSpentSeconds: 2400,
      ),
    ];
  }

  void setTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
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
    notifyListeners();
  }

  void completeActiveTask() {
    if (activeTask != null) {
      completeTaskDirectly(activeTask!);
    }
  }

  void addNewTask(Task newTask) {
    tasks.add(newTask);
    notifyListeners();
  }

  void addNewProject(Project newProject) {
    projects.add(newProject);
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
