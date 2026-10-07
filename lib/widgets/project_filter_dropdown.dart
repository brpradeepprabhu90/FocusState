import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/project.dart';

class ProjectFilterDropdown extends StatelessWidget {
  final List<Project> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;

  const ProjectFilterDropdown({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: selectedProjectId,
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
        ...projects.map((proj) {
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
        }),
      ],
      onChanged: onChanged,
    );
  }
}
