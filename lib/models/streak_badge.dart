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
    this.category = 'Garden',
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

    final gardenEmojis = ['🌱', '🌿', '☘️', '🍀', '🌸', '🌺', '🌻', '🌹', '🌷', '🌲', '🌳', '🌴', '🌵', '🌾', '🪷'];
    final energyEmojis = ['🕯️', '🔋', '⚡', '🌟', '💎', '🔮', '✨', '🏆', '👑', '🎖️'];
    final flowEmojis = ['🧘', '🌊', '🌬️', '🧘‍♂️', '🌈', '🕊️', '☁️', '🌙', '⭐', '☀️'];
    final harvestEmojis = ['🍎', '🍊', '🍇', '🍓', '🍒', '🍑', '🍐', '🫐', '🌾', '🏆'];
    final sanctuaryEmojis = ['🛋️', '🛌', '☕', '🍵', '🕯️', '🌙', '🛋️', '💆', '🧖', '✨'];

    // Category 1: Living Focus Garden (100 Flora Badges)
    for (int i = 1; i <= 100; i++) {
      final emoji = gardenEmojis[(i - 1) % gardenEmojis.length];
      badges.add(FocusBadge(
        id: 'garden_$i',
        title: i == 1 ? 'First Sprout' : 'Garden Lvl $i',
        description: 'Nurtured garden for $i days of focus',
        emoji: emoji,
        icon: Icons.filter_vintage,
        isUnlocked: currentStreak >= i || longestStreak >= i,
        category: 'Living Garden 🪴',
      ));
    }

    // Category 2: Spoon Theory Energy Trophies (100 Energy Badges)
    for (int i = 1; i <= 100; i++) {
      final emoji = energyEmojis[(i - 1) % energyEmojis.length];
      badges.add(FocusBadge(
        id: 'energy_$i',
        title: '$i Hr Energy',
        description: 'Preserved energy & logged $i+ focus hours',
        emoji: emoji,
        icon: Icons.bolt,
        isUnlocked: totalFocusHours >= i,
        category: 'Energy Trophies ⚡',
      ));
    }

    // Category 3: Mindful Flow Milestones (100 Flow Badges)
    for (int i = 1; i <= 100; i++) {
      final emoji = flowEmojis[(i - 1) % flowEmojis.length];
      badges.add(FocusBadge(
        id: 'flow_$i',
        title: '$i Flow Session${i > 1 ? 's' : ''}',
        description: 'Achieved deep flow in $i Pomodoro sessions',
        emoji: emoji,
        icon: Icons.auto_awesome,
        isUnlocked: totalPomodorosCompleted >= i,
        category: 'Mindful Flow 🧘',
      ));
    }

    // Category 4: Task Harvest Badges (100 Harvest Badges)
    for (int i = 1; i <= 100; i++) {
      final emoji = harvestEmojis[(i - 1) % harvestEmojis.length];
      badges.add(FocusBadge(
        id: 'harvest_$i',
        title: '$i Crop Harvest',
        description: 'Completed $i focus tasks in your harvest',
        emoji: emoji,
        icon: Icons.inventory_2,
        isUnlocked: totalTasksCompleted >= i,
        category: 'Task Harvest 🌾',
      ));
    }

    // Category 5: Rest & Sanctuary Badges (100 Sanctuary Badges)
    for (int i = 1; i <= 100; i++) {
      final emoji = sanctuaryEmojis[(i - 1) % sanctuaryEmojis.length];
      badges.add(FocusBadge(
        id: 'sanctuary_$i',
        title: '$i Sanctuary Day${i > 1 ? 's' : ''}',
        description: 'Achieved daily goal for $i days with zero shame',
        emoji: emoji,
        icon: Icons.bathtub,
        isUnlocked: activeDaysCount >= i,
        category: 'Rest Sanctuary 🛋️',
      ));
    }

    return badges;
  }
}
