import 'package:flutter/material.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final List<String> activeDates; // List of ISO YYYY-MM-DD strings where goal met

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.activeDates = const [],
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      activeDates: json['activeDates'] != null ? List<String>.from(json['activeDates']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'activeDates': activeDates,
    };
  }
}

class FocusBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final IconData icon;
  final bool isUnlocked;

  FocusBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.icon,
    this.isUnlocked = false,
  });

  static List<FocusBadge> getDefaultBadges({
    required int currentStreak,
    required int totalTasksCompleted,
    required double totalFocusHours,
    required bool hasSetGoal,
  }) {
    return [
      FocusBadge(
        id: 'goal_setter',
        title: 'Goal Setter',
        description: 'Set your daily Pomodoro target',
        emoji: '🎯',
        icon: Icons.track_changes,
        isUnlocked: hasSetGoal,
      ),
      FocusBadge(
        id: 'first_flow',
        title: 'First Flow',
        description: 'Complete your first focus session',
        emoji: '🚀',
        icon: Icons.bolt,
        isUnlocked: totalFocusHours > 0 || totalTasksCompleted > 0,
      ),
      FocusBadge(
        id: 'streak_3',
        title: '3-Day Streak',
        description: 'Maintain a 3-day focus streak',
        emoji: '🔥',
        icon: Icons.local_fire_department,
        isUnlocked: currentStreak >= 3,
      ),
      FocusBadge(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Maintain a 7-day focus streak',
        emoji: '🏆',
        icon: Icons.emoji_events,
        isUnlocked: currentStreak >= 7,
      ),
      FocusBadge(
        id: 'hours_10',
        title: '10 Hours Focus',
        description: 'Log 10+ hours of deep focus',
        emoji: '⏱️',
        icon: Icons.timer,
        isUnlocked: totalFocusHours >= 10,
      ),
      FocusBadge(
        id: 'task_master',
        title: 'Task Champion',
        description: 'Complete 10+ tasks',
        emoji: '✅',
        icon: Icons.verified,
        isUnlocked: totalTasksCompleted >= 10,
      ),
    ];
  }
}
