import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Project project;
  final bool isCurrentActive;
  final bool isRunning;
  final ValueChanged<Task> onCompleteTaskDirectly;
  final ValueChanged<Task> onToggleTaskTimer;
  final ValueChanged<Task>? onEditTask;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.project,
    required this.isCurrentActive,
    required this.isRunning,
    required this.onCompleteTaskDirectly,
    required this.onToggleTaskTimer,
    this.onEditTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentActive
            ? AppConstants.primaryIndigo.withOpacity(0.15)
            : (isDark ? AppConstants.darkSurface : AppConstants.lightSurface),
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
        border: Border.all(
          color: isRunning
              ? AppConstants.accentEmerald
              : (isCurrentActive ? AppConstants.primaryIndigo : Colors.transparent),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: AppConstants.accentEmerald,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: (val) {
            if (val == true) {
              onCompleteTaskDirectly(task);
            }
          },
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: project.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  project.name,
                  style: TextStyle(
                      color: project.color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${task.durationMinutes}m',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.format_list_numbered, size: 14, color: AppConstants.accentIndigoSoft),
                  const SizedBox(width: 4),
                  Text('${task.formattedCompletedPomodoros}/${task.estimatedPomodoros}',
                      style: const TextStyle(color: AppConstants.accentIndigoSoft, fontSize: 12)),
                ],
              ),
              if (task.repeatFrequency != 'Never')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      task.repeatDays != null && task.repeatDays!.isNotEmpty
                          ? '${task.repeatFrequency} (${task.repeatDays!.join(", ")})'
                          : task.repeatFrequency,
                      style: TextStyle(color: Colors.amber[600], fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEditTask != null)
              IconButton(
                icon: const Icon(Icons.edit_note, size: 24, color: AppConstants.accentIndigoSoft),
                tooltip: 'Edit Task',
                onPressed: () => onEditTask!(task),
              ),
            IconButton(
              iconSize: 36,
              icon: Icon(
                isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: isRunning ? AppConstants.warningAmber : AppConstants.primaryIndigo,
              ),
              tooltip: isRunning ? 'Pause Timer' : 'Play & Start Focus (Go to Tab 2)',
              onPressed: () => onToggleTaskTimer(task),
            ),
          ],
        ),
      ),
    );
  }
}
