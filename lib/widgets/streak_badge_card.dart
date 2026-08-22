import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/streak_badge.dart';

class StreakBadgeCard extends StatelessWidget {
  final StreakData streakData;
  final List<FocusBadge> badges;

  const StreakBadgeCard({
    Key? key,
    required this.streakData,
    required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak Banner Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryIndigo,
                AppConstants.accentIndigoSoft,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryIndigo.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streakData.currentStreak}-Day Focus Streak',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Best Streak: ${streakData.longestStreak} Days  |  Keep flowing!',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Badges Section Title
        const Text(
          'Milestone Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Badges Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = badge.isUnlocked;

            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: unlocked
                    ? (isDark ? AppConstants.darkSurface : AppConstants.lightSurface)
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked ? AppConstants.accentEmerald : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    badge.emoji,
                    style: TextStyle(
                      fontSize: 26,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: unlocked ? null : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      fontSize: 10,
                      color: unlocked ? AppConstants.accentEmerald : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
