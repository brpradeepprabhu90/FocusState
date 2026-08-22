import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/streak_badge.dart';

class StreakBadgeCard extends StatefulWidget {
  final StreakData streakData;
  final List<FocusBadge> badges;

  const StreakBadgeCard({
    Key? key,
    required this.streakData,
    required this.badges,
  }) : super(key: key);

  @override
  State<StreakBadgeCard> createState() => _StreakBadgeCardState();
}

class _StreakBadgeCardState extends State<StreakBadgeCard> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Unlocked',
    'Streaks',
    'Hours',
    'Pomodoros',
    'Tasks',
    'Goals',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unlockedCount = widget.badges.where((b) => b.isUnlocked).length;
    final totalBadges = widget.badges.length;

    List<FocusBadge> filteredBadges = widget.badges;
    if (_selectedCategory == 'Unlocked') {
      filteredBadges = widget.badges.where((b) => b.isUnlocked).toList();
    } else if (_selectedCategory != 'All') {
      filteredBadges = widget.badges.where((b) => b.category == _selectedCategory).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak & Badges Progress Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.streakData.currentStreak}-Day Focus Streak 🔥',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Badges Unlocked: $unlockedCount / $totalBadges',
                      style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title & Category Filter Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Milestone Badges (500)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Showing ${filteredBadges.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppConstants.primaryIndigo,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Compact Grid of 500 Badges
        if (filteredBadges.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text('No badges unlocked in this category yet. Keep focusing!', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredBadges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // Compact 5 columns layout
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final badge = filteredBadges[index];
              final unlocked = badge.isUnlocked;

              return Tooltip(
                message: '${badge.title}\n${badge.description}\n[${unlocked ? 'UNLOCKED' : 'LOCKED'}]',
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Row(
                          children: [
                            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(badge.title, style: const TextStyle(fontSize: 18))),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(badge.description),
                            const SizedBox(height: 12),
                            Chip(
                              label: Text(unlocked ? 'UNLOCKED 🏆' : 'LOCKED 🔒',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: unlocked ? AppConstants.accentEmerald : Colors.grey,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? AppConstants.accentEmerald.withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : Colors.black12),
                      borderRadius: BorderRadius.circular(12),
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
                            fontSize: 20, // Compact emoji icon size
                            color: unlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          badge.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9.5, // Compact text size
                            color: unlocked ? (isDark ? Colors.white : AppConstants.darkBackground) : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
