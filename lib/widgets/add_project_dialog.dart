import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';

class AddProjectDialog extends StatefulWidget {
  final Project? project;
  final Function(Project) onAddProject;
  final Function(Project)? onUpdateProject;

  const AddProjectDialog({
    Key? key,
    this.project,
    required this.onAddProject,
    this.onUpdateProject,
  }) : super(key: key);

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  static const List<Color> _colorOptions = [
    AppConstants.primaryIndigo,
    AppConstants.accentEmerald,
    AppConstants.warningAmber,
    Color(0xFFEF4444), // Crimson
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _selectedColor = widget.project?.color ?? AppConstants.primaryIndigo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.create_new_folder,
            color: AppConstants.primaryIndigo,
          ),
          const SizedBox(width: 8),
          Text(isEditing ? 'Edit Project' : 'Create New Project'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g. Mobile Development',
                prefixIcon: Icon(Icons.folder_open),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Project Color',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save, size: 16),
          label: Text(isEditing ? 'Update' : 'Save Project'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryIndigo,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              if (isEditing && widget.onUpdateProject != null) {
                widget.onUpdateProject!(
                  Project(
                    id: widget.project!.id,
                    name: name,
                    color: _selectedColor,
                  ),
                );
              } else {
                widget.onAddProject(
                  Project(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    color: _selectedColor,
                  ),
                );
              }
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}
