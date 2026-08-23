import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<Task> _tasksForDay(DateTime day) {
    return widget.tasks.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.year == day.year &&
          t.completedAt!.month == day.month &&
          t.completedAt!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDayKey = _selectedDay != null ? _formatDateKey(_selectedDay!) : null;
    final selectedTasks = _selectedDay != null ? _tasksForDay(_selectedDay!) : <Task>[];
    final selectedPomodoros = selectedTasks.fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);
    final selectedMinutes = selectedTasks.fold<int>(0, (sum, t) => sum + (t.timeSpentSeconds ~/ 60));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppConstants.primaryIndigo.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppConstants.warningAmber,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dateKey = _formatDateKey(day);
                final isGoalMet = widget.activeGoalDates.contains(dateKey);

                if (isGoalMet) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppConstants.accentEmerald.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.accentEmerald, width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.accentEmerald),
                        ),
                        const Positioned(
                          bottom: 2,
                          child: Icon(Icons.local_fire_department, size: 10, color: AppConstants.accentEmerald),
                        ),
                      ],
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Selected Day Details
        if (_selectedDay != null) ...[
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
                          '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    if (widget.activeGoalDates.contains(selectedDayKey))
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
