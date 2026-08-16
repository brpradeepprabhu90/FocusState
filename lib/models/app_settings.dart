class AppSettings {
  int defaultPomodoroMinutes;
  bool defaultAppBlockerEnabled;
  bool hapticFeedbackEnabled;
  bool notificationsEnabled;
  String? youtubeUrl;
  List<String> savedYoutubeUrls;

  AppSettings({
    this.defaultPomodoroMinutes = 25,
    this.defaultAppBlockerEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.notificationsEnabled = true,
    this.youtubeUrl,
    this.savedYoutubeUrls = const [],
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultPomodoroMinutes: json['defaultPomodoroMinutes'] ?? 25,
      defaultAppBlockerEnabled: json['defaultAppBlockerEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      youtubeUrl: json['youtubeUrl'],
      savedYoutubeUrls: json['savedYoutubeUrls'] != null ? List<String>.from(json['savedYoutubeUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultPomodoroMinutes': defaultPomodoroMinutes,
      'defaultAppBlockerEnabled': defaultAppBlockerEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'notificationsEnabled': notificationsEnabled,
      'youtubeUrl': youtubeUrl,
      'savedYoutubeUrls': savedYoutubeUrls,
    };
  }
}
