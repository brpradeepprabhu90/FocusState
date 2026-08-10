import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';

class AddProjectDialog extends StatelessWidget {
  final Function(Project) onAddProject;

  const AddProjectDialog({Key? key, required this.onAddProject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.create_new_folder, color: AppConstants.primaryIndigo),
          SizedBox(width: 8),
          Text('Create New Project'),
        ],
      ),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Project Name',
          hintText: 'e.g. Mobile Development',
          prefixIcon: Icon(Icons.folder_open),
          filled: true,
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
          label: const Text('Save Project'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryIndigo,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (nameController.text.trim().isNotEmpty) {
              onAddProject(
                Project(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  color: AppConstants.accentEmerald,
                ),
              );
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}
