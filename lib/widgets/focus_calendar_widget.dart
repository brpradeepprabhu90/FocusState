import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/task.dart';

class FocusCalendarWidget extends StatefulWidget {
  final List<String> activeGoalDates; // ISO YYYY-MM-DD strings where daily goal was met
  final List<Task> tasks;
  final int dailyGoalPomodoros;

  const FocusCalendarWidget({
    Key? key,
    required this.activeGoalDates,
    required this.tasks,
    required this.dailyGoalPomodoros,
  }) : super(key: key);

  @override
  State<FocusCalendarWidget> createState() => _FocusCalendarWidgetState();
}

class _FocusCalendarWidgetState extends State<FocusCalendarWidget> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  List<Task> _tasksForDate(DateTime dt) {
    return widget.tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == dt.year &&
          t.completedAt!.month == dt.month &&
          t.completedAt!.day == dt.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = _focusedMonth.weekday % 7; // 0 for Sunday

    final now = DateTime.now();
    final todayKey = _formatDateKey(now);

    final selectedDateKey = _selectedDate != null ? _formatDateKey(_selectedDate!) : null;
    final selectedTasks = _selectedDate != null ? _tasksForDate(_selectedDate!) : <Task>[];
    final selectedPomodoros = selectedTasks.fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);
    final selectedMinutes = selectedTasks.fold<int>(0, (sum, t) => sum + (t.timeSpentSeconds ~/ 60));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Navigation Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + firstWeekday,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              return const SizedBox();
            }

            final dayNumber = index - firstWeekday + 1;
            final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
            final dateKey = _formatDateKey(cellDate);

            final isToday = dateKey == todayKey;
            final isGoalMet = widget.activeGoalDates.contains(dateKey);
            final isSelected = dateKey == selectedDateKey;

            final dayTasks = _tasksForDate(cellDate);
            final hasActivity = dayTasks.isNotEmpty || isGoalMet;

            Color bgColor = Colors.transparent;
            Color borderColor = Colors.transparent;

            if (isGoalMet) {
              bgColor = AppConstants.accentEmerald.withValues(alpha: 0.2);
              borderColor = AppConstants.accentEmerald;
            } else if (hasActivity) {
              bgColor = AppConstants.primaryIndigo.withValues(alpha: 0.15);
              borderColor = AppConstants.primaryIndigo.withValues(alpha: 0.4);
            }

            if (isSelected) {
              borderColor = AppConstants.warningAmber;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = cellDate;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppConstants.warningAmber : (isToday ? AppConstants.primaryIndigo : borderColor),
                    width: isSelected || isToday ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isGoalMet ? AppConstants.accentEmerald : null,
                      ),
                    ),
                    if (isGoalMet)
                      const Icon(Icons.local_fire_department, size: 14, color: AppConstants.accentEmerald)
                    else if (hasActivity)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryIndigo,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Selected Date Summary Box
        if (_selectedDate != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.primaryIndigo.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: AppConstants.primaryIndigo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_monthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    if (widget.activeGoalDates.contains(selectedDateKey))
                      Chip(
                        avatar: const Icon(Icons.local_fire_department, size: 14, color: Colors.white),
                        label: const Text('Goal Met 🔥', style: TextStyle(fontSize: 11, color: Colors.white)),
                        backgroundColor: AppConstants.accentEmerald,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Completed Tasks: ${selectedTasks.length}', style: const TextStyle(fontSize: 13)),
                    ),
                    Expanded(
                      child: Text('Focus Time: ${selectedMinutes}m', style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Pomodoros: ${selectedPomodoros.toStringAsFixed(1)} / ${widget.dailyGoalPomodoros}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.accentIndigoSoft)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
