class AppSettings {
  int defaultPomodoroMinutes;
  bool defaultAppBlockerEnabled;
  bool hapticFeedbackEnabled;
  bool notificationsEnabled;
  int dailyGoalPomodoros;

  AppSettings({
    this.defaultPomodoroMinutes = 25,
    this.defaultAppBlockerEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.notificationsEnabled = true,
    this.dailyGoalPomodoros = 4,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultPomodoroMinutes: json['defaultPomodoroMinutes'] ?? 25,
      defaultAppBlockerEnabled: json['defaultAppBlockerEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyGoalPomodoros: json['dailyGoalPomodoros'] ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultPomodoroMinutes': defaultPomodoroMinutes,
      'defaultAppBlockerEnabled': defaultAppBlockerEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'notificationsEnabled': notificationsEnabled,
      'dailyGoalPomodoros': dailyGoalPomodoros,
    };
  }
}
