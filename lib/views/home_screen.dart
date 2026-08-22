import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../widgets/settings_modal.dart';
import 'tasks_tab.dart';
import 'timer_tab.dart';
import 'stats_tab.dart';
import '../controllers/app_controller.dart';

import 'permission_onboarding_dialog.dart';

class MainHomeScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const MainHomeScreen({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.init().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PermissionOnboardingDialog.showIfNeeded(context);
      });
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SettingsModal(
        settings: _controller.settings,
        currentThemeMode: widget.currentThemeMode,
        onThemeChanged: widget.onThemeChanged,
        onRequestBackgroundUsage: () async {
          final success = await _controller.requestBackgroundUsage();
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.battery_charging_full, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Requested background battery optimization exemption.'),
                  ],
                ),
              ),
            );
          }
        },
        onSaveSettings: _controller.updateSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (!_controller.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final screens = [
          TasksAndRemindersTab(
            projects: _controller.projects,
            tasks: _controller.tasks,
            activeTask: _controller.activeTask,
            isTimerRunning: _controller.isTimerRunning,
            onToggleTaskTimer: _controller.toggleTaskTimer,
            onCompleteTaskDirectly: (task) {
              _controller.completeTaskDirectly(task);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Task "${task.title}" completed!')),
                    ],
                  ),
                  backgroundColor: AppConstants.accentEmerald,
                ),
              );
            },
            onAddTask: _controller.addNewTask,
            onUpdateTask: _controller.updateTask,
            onAddProject: _controller.addNewProject,
            onUpdateProject: _controller.updateProject,
            onDeleteProject: _controller.deleteProject,
          ),
          TimerTab(
            activeTask: _controller.activeTask,
            isTimerRunning: _controller.isTimerRunning,
            settings: _controller.settings,
            onPauseTimer: _controller.pauseTimer,
            onResumeTimer: _controller.resumeTimer,
            onCompleteTask: _controller.completeActiveTask,
            onSelectTaskPrompt: () {
              _controller.setTabIndex(0);
            },
            onSaveSettings: () {
              _controller.saveSettings();
            },
          ),
          StatsProgressTab(
            projects: _controller.projects,
            tasks: _controller.tasks,
            settings: _controller.settings,
            streakData: _controller.streakData,
            onUpdateDailyGoal: _controller.updateDailyGoal,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: const [
                Icon(Icons.bolt, color: AppConstants.primaryIndigo),
                SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.amber),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  widget.onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppConstants.accentIndigoSoft),
                tooltip: 'App Settings',
                onPressed: _showSettingsModal,
              ),
            ],
          ),
          body: IndexedStack(
            index: _controller.selectedTabIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _controller.selectedTabIndex,
            onDestinationSelected: _controller.setTabIndex,
            indicatorColor: AppConstants.primaryIndigo.withOpacity(0.3),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder, color: AppConstants.accentIndigoSoft),
                label: '1. Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer, color: AppConstants.accentIndigoSoft),
                label: '2. Focus Timer',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month, color: AppConstants.accentIndigoSoft),
                label: '3. Calendar & Streaks',
              ),
            ],
          ),
        );
      },
    );
  }
}
