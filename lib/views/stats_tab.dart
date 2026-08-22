import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/streak_badge.dart';

import '../services/report_exporter_service.dart';
import '../widgets/daily_goal_modal.dart';
import '../widgets/focus_calendar_widget.dart';
import '../widgets/streak_badge_card.dart';
import '../widgets/stat_card.dart';

class StatsProgressTab extends StatelessWidget {
  final List<Project> projects;
  final List<Task> tasks;
  final AppSettings settings;
  final StreakData streakData;
  final ValueChanged<int> onUpdateDailyGoal;

  const StatsProgressTab({
    Key? key,
    required this.projects,
    required this.tasks,
    required this.settings,
    required this.streakData,
    required this.onUpdateDailyGoal,
  }) : super(key: key);

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0m';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  void _showSetGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DailyGoalModal(
        currentGoalPomodoros: settings.dailyGoalPomodoros,
        onSaveGoal: onUpdateDailyGoal,
      ),
    );
  }

  void _exportCsvReport(BuildContext context) async {
    final success = await ReportExporterService.exportCsvReport(
      context: context,
      projects: projects,
      tasks: tasks,
      currentStreak: streakData.currentStreak,
      dailyGoalPomodoros: settings.dailyGoalPomodoros,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Productivity CSV report exported successfully!'),
              ],
            ),
            backgroundColor: AppConstants.accentEmerald,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final todayPomodoros = tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);

    final todaySeconds = tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);

    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final weekSeconds = tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
    }).fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);

    final totalSeconds = tasks.fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);

    final goalTarget = settings.dailyGoalPomodoros.toDouble();
    final goalProgress = goalTarget > 0 ? (todayPomodoros / goalTarget).clamp(0.0, 1.0) : 0.0;
    final isGoalAchieved = todayPomodoros >= goalTarget;

    final totalCompletedTasks = tasks.where((t) => t.isCompleted).length;
    final totalFocusHours = totalSeconds / 3600.0;
    final totalPomodorosCompleted = tasks.fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);

    final badges = FocusBadge.generate500Badges(
      currentStreak: streakData.currentStreak,
      longestStreak: streakData.longestStreak,
      totalTasksCompleted: totalCompletedTasks,
      totalFocusHours: totalFocusHours,
      totalPomodorosCompleted: totalPomodorosCompleted,
      activeDaysCount: streakData.activeDates.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Title & Export Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, color: AppConstants.primaryIndigo, size: 28),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Focus Calendar',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.track_changes, size: 16),
                    label: const Text('Set Goal'),
                    onPressed: () => _showSetGoalModal(context),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('CSV Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryIndigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _exportCsvReport(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Track daily goals, streaks, and milestone achievements', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // Focus Time Breakdown Cards (Today, This Week, Total)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Focus Today',
                  value: _formatDuration(todaySeconds),
                  icon: Icons.today,
                  color: AppConstants.accentEmerald,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: 'This Week',
                  value: _formatDuration(weekSeconds),
                  icon: Icons.date_range,
                  color: AppConstants.primaryIndigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: 'Total Focus',
                  value: _formatDuration(totalSeconds),
                  icon: Icons.all_inclusive,
                  color: AppConstants.warningAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Daily Goal Progress Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isGoalAchieved ? AppConstants.accentEmerald : AppConstants.primaryIndigo.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isGoalAchieved ? Icons.verified : Icons.flag,
                          color: isGoalAchieved ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
                        ),
                        const SizedBox(width: 8),
                        const Text('Today\'s Daily Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isGoalAchieved ? AppConstants.accentEmerald : AppConstants.primaryIndigo).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Target: ${settings.dailyGoalPomodoros} Poms (${settings.dailyGoalPomodoros * 25}m)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isGoalAchieved ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Goal Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    minHeight: 12,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGoalAchieved ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed Today: ${todayPomodoros.toStringAsFixed(1)} / ${settings.dailyGoalPomodoros} Pomodoros',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    if (isGoalAchieved)
                      Row(
                        children: const [
                          Icon(Icons.local_fire_department, size: 16, color: AppConstants.accentEmerald),
                          SizedBox(width: 4),
                          Text(
                            'Goal Achieved!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.accentEmerald,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Streak & Milestones Section
          StreakBadgeCard(
            streakData: streakData,
            badges: badges,
          ),
          const SizedBox(height: 24),

          // Interactive Monthly Calendar View
          const Text(
            'Monthly Activity Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Days highlighted in green indicating goal met (🔥)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),

          FocusCalendarWidget(
            activeGoalDates: streakData.activeDates,
            tasks: tasks,
            dailyGoalPomodoros: settings.dailyGoalPomodoros,
          ),
        ],
      ),
    );
  }
}
