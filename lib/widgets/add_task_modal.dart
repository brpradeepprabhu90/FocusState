import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';
import '../models/task.dart';

class AddTaskModal extends StatefulWidget {
  final List<Project> projects;
  final String? initialProjectId;
  final Function(Task) onAddTask;

  const AddTaskModal({
    Key? key,
    required this.projects,
    this.initialProjectId,
    required this.onAddTask,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  late String _selectedProjId;
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _reminderController = TextEditingController(text: '12:00 PM');
  String _repeatFrequency = AppConstants.repeatOptions.first;
  bool _enableNotification = true;
  int _estimatedPomodoros = 1;
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late final List<String> _selectedDays = List.from(_weekDays);

  @override
  void initState() {
    super.initState();
    _selectedProjId = widget.initialProjectId ?? widget.projects.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.add_task, color: AppConstants.accentIndigoSoft),
                  SizedBox(width: 8),
                  Text(
                    'Create Task & Schedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedProjId,
            decoration: InputDecoration(
              labelText: 'Assigned Project',
              prefixIcon: const Icon(Icons.folder, color: AppConstants.accentIndigoSoft),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: widget.projects
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedProjId = val;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              prefixIcon: const Icon(Icons.edit_note, color: AppConstants.accentIndigoSoft),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Est. Focus (Mins)',
                    prefixIcon: const Icon(Icons.timer, color: AppConstants.accentIndigoSoft),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _reminderController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Time',
                    prefixIcon: const Icon(Icons.alarm, color: AppConstants.accentIndigoSoft),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _repeatFrequency,
            decoration: InputDecoration(
              labelText: 'Repeat Schedule',
              prefixIcon: const Icon(Icons.repeat, color: AppConstants.accentIndigoSoft),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: AppConstants.repeatOptions
                .map((opt) => DropdownMenuItem(value: opt, child: Text('Repeat $opt')))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _repeatFrequency = val;
                  if (val == 'Weekly' && _selectedDays.isEmpty) {
                    _selectedDays.addAll(_weekDays);
                  } else if (val != 'Weekly') {
                    _selectedDays.clear();
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _estimatedPomodoros,
            decoration: InputDecoration(
              labelText: 'Estimated Pomodoros',
              prefixIcon: const Icon(Icons.format_list_numbered, color: AppConstants.accentIndigoSoft),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: List.generate(10, (index) => index + 1)
                .map((opt) => DropdownMenuItem(value: opt, child: Text('$opt Pomodoro${opt > 1 ? 's' : ''}')))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _estimatedPomodoros = val;
                });
              }
            },
          ),
          if (_repeatFrequency == 'Weekly') ...[
            const SizedBox(height: 12),
            const Text('Select Days:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _weekDays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  selectedColor: AppConstants.primaryIndigo,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: AppConstants.accentEmerald),
            title: const Text('Notification Alert'),
            subtitle: const Text('Trigger push notification when timer completes'),
            value: _enableNotification,
            activeColor: AppConstants.primaryIndigo,
            onChanged: (val) {
              setState(() {
                _enableNotification = val;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Task', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  widget.onAddTask(
                    Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: _selectedProjId,
                      title: _titleController.text.trim(),
                      durationMinutes: int.tryParse(_durationController.text) ?? 25,
                      reminderTime: _reminderController.text.trim(),
                      repeatFrequency: _repeatFrequency,
                      repeatDays: _selectedDays.isNotEmpty ? List.from(_selectedDays) : null,
                      enableNotification: _enableNotification,
                      estimatedPomodoros: _estimatedPomodoros,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
