import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectPendingCard extends StatelessWidget {
  final Project project;
  final List<Task> pendingTasks;

  const ProjectPendingCard({
    Key? key,
    required this.project,
    required this.pendingTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: project.color.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open, color: project.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${project.name} (${pendingTasks.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: project.color,
                  ),
                ),
              ],
            ),
          ),
          if (pendingTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No pending tasks in this project.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ...pendingTasks.map(
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
                    if (t.interruptedPomodoros > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppConstants.warningAmber),
                      const SizedBox(width: 4),
                      Text('${t.interruptedPomodoros}', style: const TextStyle(fontSize: 12, color: AppConstants.warningAmber)),
                    ],
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
  }
}
