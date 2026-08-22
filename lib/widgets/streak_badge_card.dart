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
  String _selectedCategory = 'All Earned';

  final List<String> _categories = [
    'All Earned',
    'Living Garden 🪴',
    'Energy Trophies ⚡',
    'Mindful Flow 🧘',
    'Task Harvest 🌾',
    'Rest Sanctuary 🛋️',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter ONLY UNLOCKED badges to avoid overwhelming the user with empty boxes
    List<FocusBadge> earnedCategoryBadges = widget.badges.where((b) => b.isUnlocked).toList();
    if (_selectedCategory != 'All Earned') {
      earnedCategoryBadges = earnedCategoryBadges.where((b) => b.category == _selectedCategory).toList();
    }

    // Single next milestone teaser (blurred silhouette)
    final nextMilestone = _selectedCategory == 'All Earned'
        ? widget.badges.where((b) => !b.isUnlocked).firstOrNull
        : widget.badges.where((b) => !b.isUnlocked && b.category == _selectedCategory).firstOrNull;

    final totalEarned = widget.badges.where((b) => b.isUnlocked).length;

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
                child: const Text('🪴', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Garden Vitality: ${widget.streakData.currentStreak} Days Nourished',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('🌿', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Living Garden • $totalEarned Trophies Earned',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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
        const SizedBox(height: 16),

        // Living Garden Landscape View vs Category Grid
        if (_selectedCategory == 'Living Garden 🪴' || _selectedCategory == 'All Earned')
          _buildGardenLandscapeMeadow(earnedCategoryBadges, nextMilestone, isDark)
        else
          _buildEarnedGridWithTeaser(earnedCategoryBadges, nextMilestone, isDark),
      ],
    );
  }

  Widget _buildGardenLandscapeMeadow(List<FocusBadge> earnedBadges, FocusBadge? nextMilestone, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF0F766E), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.park, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Your Blooming Garden Meadow 🌸',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${earnedBadges.length} Blooming',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Each focus session nurtures your ecosystem. No finish line—just continuous growth.',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          // Organic Flora Grid Landscape
          if (earnedBadges.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '🌱 Your garden is starting to sprout.\nComplete your first focus session to bloom your first flora!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...earnedBadges.map((badge) => Tooltip(
                      message: '${badge.title}\n${badge.description}',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(badge.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 4),
                            Text(
                              badge.title,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (nextMilestone != null)
                  Tooltip(
                    message: 'Next Milestone: ${nextMilestone.description}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: Text(nextMilestone.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Next Bloom 🌱',
                            style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEarnedGridWithTeaser(List<FocusBadge> earnedBadges, FocusBadge? nextMilestone, bool isDark) {
    final displayItemsCount = earnedBadges.length + (nextMilestone != null ? 1 : 0);

    if (earnedBadges.isEmpty && nextMilestone == null) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text('No trophies earned in this category yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayItemsCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        if (index < earnedBadges.length) {
          final badge = earnedBadges[index];
          return Tooltip(
            message: '${badge.title}\n${badge.description}',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.accentEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.accentEmerald, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    badge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isDark ? Colors.white : AppConstants.darkBackground,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        } else {
          // Blurred Soft Silhouette Teaser Card
          return Tooltip(
            message: 'Next Horizon: ${nextMilestone!.description}',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Text(nextMilestone.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Next Reward 🔮',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
