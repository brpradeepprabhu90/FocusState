import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class EnergySelectorWidget extends StatelessWidget {
  final String currentEnergyLevel;
  final ValueChanged<String> onEnergyChanged;

  const EnergySelectorWidget({
    Key? key,
    required this.currentEnergyLevel,
    required this.onEnergyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = [
      {'id': 'High', 'label': 'High ⚡', 'color': AppConstants.accentEmerald},
      {'id': 'Moderate', 'label': 'Moderate 🔋', 'color': AppConstants.primaryIndigo},
      {'id': 'Low', 'label': 'Burnout / Low 🕯️', 'color': AppConstants.warningAmber},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: levels.map((lvl) {
          final isSelected = currentEnergyLevel == lvl['id'];
          final color = lvl['color'] as Color;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () => onEnergyChanged(lvl['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  lvl['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
