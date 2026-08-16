import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';

// Widgets
import '../widgets/stat_card.dart';
import '../widgets/completion_progress_bar.dart';
import '../widgets/expandable_completed_card.dart';
import '../widgets/project_pending_card.dart';

class StatsProgressTab extends StatelessWidget {
  final List<Project> projects;
  final List<Task> tasks;

  const StatsProgressTab({Key? key, required this.projects, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

    final totalCount = tasks.length;
    final completedCount = completedTasks.length;
    final pendingCount = pendingTasks.length;
    final completionRatio = totalCount > 0 ? completedCount / totalCount : 0.0;

    final totalMinutesSpent = tasks.fold<int>(0, (sum, t) => sum + (t.timeSpentSeconds ~/ 60));

    // Completed Grouping: Today, Current Month, Current Year
    final now = DateTime.now();

    final todayCompleted = completedTasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).toList();

    final monthCompleted = completedTasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year && t.completedAt!.month == now.month;
    }).toList();

    final yearCompleted = completedTasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == now.year;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insights, color: AppConstants.primaryIndigo, size: 28),
              SizedBox(width: 8),
              Text(
                'Progress & Performance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Overview of completed vs pending tasks', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // Overview Cards Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Completed',
                  value: '$completedCount',
                  icon: Icons.task_alt,
                  color: AppConstants.accentEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_actions,
                  color: AppConstants.warningAmber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Total Time',
                  value: '${totalMinutesSpent}m',
                  icon: Icons.timer,
                  color: AppConstants.primaryIndigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Completion Progress Bar
          CompletionProgressBar(completionRatio: completionRatio),
          const SizedBox(height: 24),

          // Detailed Completed & Pending Lists
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppConstants.primaryIndigo,
                    labelColor: AppConstants.accentIndigoSoft,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16),
                            const SizedBox(width: 6),
                            Text('Completed ($completedCount)'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_copy_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text('Pending ($pendingCount)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // COMPLETED: Interactive Expandable Cards with Icons
                        ListView(
                          children: [
                            ExpandableCompletedCard(
                              title: 'Today',
                              groupIcon: Icons.today,
                              count: todayCompleted.length,
                              color: AppConstants.accentEmerald,
                              tasks: todayCompleted,
                            ),
                            const SizedBox(height: 12),
                            ExpandableCompletedCard(
                              title: 'This Month',
                              groupIcon: Icons.calendar_month,
                              count: monthCompleted.length,
                              color: AppConstants.primaryIndigo,
                              tasks: monthCompleted,
                            ),
                            const SizedBox(height: 12),
                            ExpandableCompletedCard(
                              title: 'This Year',
                              groupIcon: Icons.calendar_today,
                              count: yearCompleted.length,
                              color: AppConstants.warningAmber,
                              tasks: yearCompleted,
                            ),
                          ],
                        ),

                        // PENDING: Grouped by Projects with Icons
                        ListView(
                          children: projects.map((proj) {
                            final projPending = pendingTasks.where((t) => t.projectId == proj.id).toList();
                            return ProjectPendingCard(project: proj, pendingTasks: projPending);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
