import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class DailyGoalModal extends StatefulWidget {
  final int currentGoalPomodoros;
  final ValueChanged<int> onSaveGoal;

  const DailyGoalModal({
    Key? key,
    required this.currentGoalPomodoros,
    required this.onSaveGoal,
  }) : super(key: key);

  @override
  State<DailyGoalModal> createState() => _DailyGoalModalState();
}

class _DailyGoalModalState extends State<DailyGoalModal> {
  late int _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.currentGoalPomodoros;
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
                  Icon(Icons.track_changes, color: AppConstants.primaryIndigo, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Set Daily Focus Goal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose how many Pomodoro sessions (25m each) you want to complete each day to maintain your streak.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<int>(
            value: _selectedGoal,
            decoration: InputDecoration(
              labelText: 'Daily Goal Target',
              prefixIcon: const Icon(Icons.stars, color: Colors.amber),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: List.generate(12, (index) => index + 1)
                .map((count) => DropdownMenuItem(
                      value: count,
                      child: Text('$count Pomodoro${count > 1 ? 's' : ''} (${count * 25} minutes)'),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedGoal = val;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Save Daily Goal', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onSaveGoal(_selectedGoal);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
