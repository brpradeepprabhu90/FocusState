class AppSettings {
  int defaultPomodoroMinutes;
  bool defaultAppBlockerEnabled;
  bool hapticFeedbackEnabled;
  bool notificationsEnabled;
  AppSettings({
    this.defaultPomodoroMinutes = 25,
    this.defaultAppBlockerEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.notificationsEnabled = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultPomodoroMinutes: json['defaultPomodoroMinutes'] ?? 25,
      defaultAppBlockerEnabled: json['defaultAppBlockerEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultPomodoroMinutes': defaultPomodoroMinutes,
      'defaultAppBlockerEnabled': defaultAppBlockerEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
