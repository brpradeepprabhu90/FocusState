import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/add_task_modal.dart';

// Extracted Widgets
import '../widgets/project_filter_dropdown.dart';
import '../widgets/task_list_item.dart';

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
          ProjectFilterDropdown(
            projects: widget.projects,
            selectedProjectId: _selectedProjectId,
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

                  return TaskListItem(
                    task: task,
                    project: proj,
                    isCurrentActive: isCurrentActive,
                    isRunning: isRunning,
                    onCompleteTaskDirectly: widget.onCompleteTaskDirectly,
                    onToggleTaskTimer: widget.onToggleTaskTimer,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
