class Task {
  final String id;
  String projectId;
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
  double completedPomodoros;
  int interruptedPomodoros;

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
    this.completedPomodoros = 0.0,
    this.interruptedPomodoros = 0,
  });

  String get formattedCompletedPomodoros {
    final val = double.parse(completedPomodoros.toStringAsFixed(2));
    if (val == val.toInt().toDouble()) {
      return val.toInt().toString();
    }
    return val.toString().replaceAll(RegExp(r'0+$'), '');
  }

  void updateCalculatedPomodoros() {
    if (durationMinutes > 0) {
      final computed = timeSpentSeconds / (durationMinutes * 60);
      completedPomodoros = double.parse(computed.toStringAsFixed(2));
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      reminderTime: json['reminderTime'],
      repeatFrequency: json['repeatFrequency'] ?? 'Never',
      repeatDays: json['repeatDays'] != null ? List<String>.from(json['repeatDays']) : null,
      enableNotification: json['enableNotification'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      estimatedPomodoros: json['estimatedPomodoros'] ?? 1,
      completedPomodoros: (json['completedPomodoros'] as num?)?.toDouble() ?? 0.0,
      interruptedPomodoros: json['interruptedPomodoros'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'durationMinutes': durationMinutes,
      'reminderTime': reminderTime,
      'repeatFrequency': repeatFrequency,
      'repeatDays': repeatDays,
      'enableNotification': enableNotification,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'interruptedPomodoros': interruptedPomodoros,
    };
  }
}
