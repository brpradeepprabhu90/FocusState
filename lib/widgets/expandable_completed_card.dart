import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/task.dart';

class ExpandableCompletedCard extends StatelessWidget {
  final String title;
  final IconData groupIcon;
  final int count;
  final Color color;
  final List<Task> tasks;

  const ExpandableCompletedCard({
    Key? key,
    required this.title,
    required this.groupIcon,
    required this.count,
    required this.color,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  subtitle: Row(
                    children: [
                      Text('Pomodoros: ${t.completedPomodoros} / ${t.estimatedPomodoros}'),
                      if (t.interruptedPomodoros > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.warning_amber_rounded, size: 12, color: AppConstants.warningAmber),
                        const SizedBox(width: 4),
                        Text('Interrupted: ${t.interruptedPomodoros}', style: const TextStyle(fontSize: 12, color: AppConstants.warningAmber)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
