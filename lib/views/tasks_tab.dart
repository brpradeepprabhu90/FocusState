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
  final Function(Task)? onUpdateTask;
  final Function(Project) onAddProject;
  final Function(Project)? onUpdateProject;
  final Function(String)? onDeleteProject;

  const TasksAndRemindersTab({
    Key? key,
    required this.projects,
    required this.tasks,
    required this.activeTask,
    required this.isTimerRunning,
    required this.onToggleTaskTimer,
    required this.onCompleteTaskDirectly,
    required this.onAddTask,
    this.onUpdateTask,
    required this.onAddProject,
    this.onUpdateProject,
    this.onDeleteProject,
  }) : super(key: key);

  @override
  State<TasksAndRemindersTab> createState() => _TasksAndRemindersTabState();
}

class _TasksAndRemindersTabState extends State<TasksAndRemindersTab> {
  String? _selectedProjectId;

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddProjectDialog(
        onAddProject: widget.onAddProject,
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AddProjectDialog(
        project: project,
        onAddProject: widget.onAddProject,
        onUpdateProject: widget.onUpdateProject,
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? Tasks associated with this project will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onDeleteProject != null) {
                widget.onDeleteProject!(project.id);
                setState(() {
                  _selectedProjectId = null;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        onUpdateTask: widget.onUpdateTask,
      ),
    );
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTaskModal(
        projects: widget.projects,
        taskToEdit: task,
        onAddTask: widget.onAddTask,
        onUpdateTask: widget.onUpdateTask,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = widget.projects.where((p) => p.id == _selectedProjectId).firstOrNull;

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

          // Project Filter Dropdown & Controls
          ProjectFilterDropdown(
            projects: widget.projects,
            selectedProjectId: _selectedProjectId,
            onChanged: (val) {
              setState(() {
                _selectedProjectId = val;
              });
            },
          ),

          if (selectedProject != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selectedProject.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedProject.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, size: 18, color: selectedProject.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedProject.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedProject.color,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit Project',
                    onPressed: () => _showEditProjectDialog(context, selectedProject),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    tooltip: 'Delete Project',
                    onPressed: () => _confirmDeleteProject(context, selectedProject),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Tasks Grouped View
          if (filteredTasks.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      widget.projects.isEmpty
                          ? 'No projects created yet. Click "+ Project" to create one.'
                          : 'No pending tasks in this project. Click "+" to create one.',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
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
                    onEditTask: (t) => _showEditTaskBottomSheet(context, t),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
