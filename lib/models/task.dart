class Task {
  final String id;
  final String projectId;
  final String title;
  final int durationMinutes; // total estimated minutes
  final String? reminderTime; // e.g. "14:30" or "In 10 mins"
  final String repeatFrequency; // 'Never', 'Daily', 'Weekly', 'Monthly'
  final List<String>? repeatDays; // e.g. ['Mon', 'Wed', 'Fri']
  final bool enableNotification;
  bool isCompleted;
  DateTime? completedAt;
  int timeSpentSeconds;
  final int estimatedPomodoros;
  int completedPomodoros;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.durationMinutes,
    this.reminderTime,
    this.repeatFrequency = 'Never',
    this.repeatDays,
    this.enableNotification = true,
    this.isCompleted = false,
    this.completedAt,
    this.timeSpentSeconds = 0,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
  });
}
