import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: _buildStatCard(
                  context: context,
                  title: 'Completed',
                  value: '$completedCount',
                  icon: Icons.task_alt,
                  color: AppConstants.accentEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_actions,
                  color: AppConstants.warningAmber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                      children: const [
                        Icon(Icons.pie_chart, size: 18, color: AppConstants.accentIndigoSoft),
                        SizedBox(width: 8),
                        Text('Task Completion Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('${(completionRatio * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.accentEmerald)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionRatio,
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.accentEmerald),
                  ),
                ),
              ],
            ),
          ),
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
                            _buildExpandableCompletedCard(
                              context: context,
                              title: 'Today',
                              groupIcon: Icons.today,
                              count: todayCompleted.length,
                              color: AppConstants.accentEmerald,
                              tasks: todayCompleted,
                            ),
                            const SizedBox(height: 12),
                            _buildExpandableCompletedCard(
                              context: context,
                              title: 'This Month',
                              groupIcon: Icons.calendar_month,
                              count: monthCompleted.length,
                              color: AppConstants.primaryIndigo,
                              tasks: monthCompleted,
                            ),
                            const SizedBox(height: 12),
                            _buildExpandableCompletedCard(
                              context: context,
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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: proj.color.withOpacity(0.15),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.folder_open, color: proj.color, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${proj.name} (${projPending.length})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: proj.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (projPending.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No pending tasks in this project.',
                                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                                    )
                                  else
                                    ...projPending.map(
                                      (t) => ListTile(
                                        leading: const Icon(Icons.radio_button_unchecked, color: Colors.amber, size: 20),
                                        title: Text(t.title),
                                        subtitle: Row(
                                          children: [
                                            const Icon(Icons.schedule, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text('${t.durationMinutes}m', style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.format_list_numbered, size: 12, color: Colors.indigo),
                                            const SizedBox(width: 4),
                                            Text('${t.completedPomodoros}/${t.estimatedPomodoros}', style: const TextStyle(fontSize: 12)),
                                            if (t.repeatFrequency != 'Never') ...[
                                              const SizedBox(width: 8),
                                              const Icon(Icons.repeat, size: 12, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(t.repeatFrequency, style: const TextStyle(fontSize: 12, color: Colors.amber)),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
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

  Widget _buildExpandableCompletedCard({
    required BuildContext context,
    required String title,
    required IconData groupIcon,
    required int count,
    required Color color,
    required List<Task> tasks,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(groupIcon, color: color, size: 20),
          ),
          title: Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '$count Completed ${count == 1 ? "Task" : "Tasks"} — Tap to view list',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          children: [
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('No tasks completed in this period.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            else
              ...tasks.map(
                (t) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle, color: AppConstants.accentEmerald, size: 20),
                  title: Text(t.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                  subtitle: Text('Pomodoros: ${t.completedPomodoros} / ${t.estimatedPomodoros}'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
