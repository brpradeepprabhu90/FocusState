import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/add_task_modal.dart';

class TasksAndRemindersTab extends StatefulWidget {
  final List<Project> projects;
  final List<Task> tasks;
  final Task? activeTask;
  final bool isTimerRunning;
  final Function(Task) onToggleTaskTimer;
  final Function(Task) onCompleteTaskDirectly;
  final Function(Task) onAddTask;
  final Function(Project) onAddProject;

  const TasksAndRemindersTab({
    Key? key,
    required this.projects,
    required this.tasks,
    required this.activeTask,
    required this.isTimerRunning,
    required this.onToggleTaskTimer,
    required this.onCompleteTaskDirectly,
    required this.onAddTask,
    required this.onAddProject,
  }) : super(key: key);

  @override
  State<TasksAndRemindersTab> createState() => _TasksAndRemindersTabState();
}

class _TasksAndRemindersTabState extends State<TasksAndRemindersTab> {
  String? _selectedProjectId;

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddProjectDialog(onAddProject: widget.onAddProject),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTaskModal(
        projects: widget.projects,
        initialProjectId: _selectedProjectId,
        onAddTask: widget.onAddTask,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedProjectId == null
        ? widget.tasks.where((t) => !t.isCompleted).toList()
        : widget.tasks.where((t) => !t.isCompleted && t.projectId == _selectedProjectId).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.folder, color: AppConstants.primaryIndigo, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Projects & Tasks',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.create_new_folder, size: 18),
                    label: const Text('Project'),
                    onPressed: () => _showAddProjectDialog(context),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: () => _showAddTaskBottomSheet(context),
                    backgroundColor: AppConstants.primaryIndigo,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project Filter Dropdown
          DropdownButtonFormField<String?>(
            value: _selectedProjectId,
            decoration: InputDecoration(
              labelText: 'Filter by Project',
              prefixIcon: const Icon(Icons.filter_alt, color: AppConstants.primaryIndigo),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Projects'),
              ),
              ...widget.projects.map((proj) {
                return DropdownMenuItem<String?>(
                  value: proj.id,
                  child: Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: proj.color),
                      const SizedBox(width: 8),
                      Text(proj.name),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: (val) {
              setState(() {
                _selectedProjectId = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Tasks Grouped View
          if (filteredTasks.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No pending tasks in this project. Click "+" to create one.',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final isCurrentActive = widget.activeTask?.id == task.id;
                  final isRunning = isCurrentActive && widget.isTimerRunning;

                  final proj = widget.projects.firstWhere(
                    (p) => p.id == task.projectId,
                    orElse: () => Project(id: '0', name: 'General', color: Colors.grey),
                  );

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
                            widget.onCompleteTaskDirectly(task);
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
                                color: proj.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                proj.name,
                                style: TextStyle(
                                    color: proj.color, fontSize: 11, fontWeight: FontWeight.bold),
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
                                Text('${task.completedPomodoros}/${task.estimatedPomodoros}',
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
                      trailing: IconButton(
                        iconSize: 36,
                        icon: Icon(
                          isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: isRunning ? AppConstants.warningAmber : AppConstants.primaryIndigo,
                        ),
                        tooltip: isRunning ? 'Pause Timer' : 'Play & Start Focus (Go to Tab 2)',
                        onPressed: () => widget.onToggleTaskTimer(task),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
