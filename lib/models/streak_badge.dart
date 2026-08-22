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
  final String category;

  FocusBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.icon,
    this.isUnlocked = false,
    this.category = 'General',
  });

  static List<FocusBadge> generate500Badges({
    required int currentStreak,
    required int longestStreak,
    required int totalTasksCompleted,
    required double totalFocusHours,
    required double totalPomodorosCompleted,
    required int activeDaysCount,
  }) {
    final List<FocusBadge> badges = [];

    // Track 1: Streak Badges (100 Badges: 1 to 100 Days)
    for (int i = 1; i <= 100; i++) {
      badges.add(FocusBadge(
        id: 'streak_$i',
        title: '$i-Day Streak',
        description: 'Maintain a $i-day focus streak',
        emoji: i >= 30 ? '👑' : (i >= 10 ? '🏆' : '🔥'),
        icon: Icons.local_fire_department,
        isUnlocked: currentStreak >= i || longestStreak >= i,
        category: 'Streaks',
      ));
    }

    // Track 2: Focus Hours Badges (100 Badges: 1 to 100 Hours)
    for (int i = 1; i <= 100; i++) {
      badges.add(FocusBadge(
        id: 'hours_$i',
        title: '$i Hr${i > 1 ? 's' : ''}',
        description: 'Log $i+ hours of focus',
        emoji: i >= 50 ? '💎' : '⏱️',
        icon: Icons.timer,
        isUnlocked: totalFocusHours >= i,
        category: 'Hours',
      ));
    }

    // Track 3: Pomodoro Session Badges (100 Badges: 1 to 100 Pomodoros)
    for (int i = 1; i <= 100; i++) {
      badges.add(FocusBadge(
        id: 'pom_$i',
        title: '$i Pom${i > 1 ? 's' : ''}',
        description: 'Complete $i Pomodoro focus sessions',
        emoji: i >= 50 ? '🌟' : '⚡',
        icon: Icons.bolt,
        isUnlocked: totalPomodorosCompleted >= i,
        category: 'Pomodoros',
      ));
    }

    // Track 4: Task Completion Badges (100 Badges: 1 to 100 Tasks)
    for (int i = 1; i <= 100; i++) {
      badges.add(FocusBadge(
        id: 'task_$i',
        title: '$i Task${i > 1 ? 's' : ''}',
        description: 'Complete $i tasks',
        emoji: i >= 50 ? '🏅' : '✅',
        icon: Icons.check_circle,
        isUnlocked: totalTasksCompleted >= i,
        category: 'Tasks',
      ));
    }

    // Track 5: Active Days Goal Badges (100 Badges: 1 to 100 Goal Days)
    for (int i = 1; i <= 100; i++) {
      badges.add(FocusBadge(
        id: 'goal_day_$i',
        title: '$i Goal Day${i > 1 ? 's' : ''}',
        description: 'Achieve daily goal for $i days',
        emoji: i >= 50 ? '🎖️' : '🎯',
        icon: Icons.track_changes,
        isUnlocked: activeDaysCount >= i,
        category: 'Goals',
      ));
    }

    return badges;
  }
}
