import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AmbientSoundSelector extends StatelessWidget {
  final String selectedSound;
  final double soundVolume;
  final ValueChanged<String?> onSoundSelected;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;

  const AmbientSoundSelector({
    Key? key,
    required this.selectedSound,
    required this.soundVolume,
    required this.onSoundSelected,
    required this.onVolumeChanged,
    required this.onToggleMute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedSound != 'None'
              ? AppConstants.primaryIndigo.withOpacity(0.5)
              : Colors.transparent,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                  Icon(Icons.graphic_eq, color: AppConstants.primaryIndigo, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ambient Focus Sound',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: selectedSound,
                underline: const SizedBox(),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('🔇 None')),
                  DropdownMenuItem(value: 'Monsoon Breath', child: Text('🌧️ Monsoon Breath')),
                  DropdownMenuItem(value: 'Morning at the Ghat', child: Text('🌅 Morning at the Ghat')),
                  DropdownMenuItem(value: 'The Breathing Tide', child: Text('🌊 The Breathing Tide')),
                ],
                onChanged: onSoundSelected,
              ),
            ],
          ),
          if (selectedSound != 'None') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      soundVolume == 0
                          ? Icons.volume_off
                          : (soundVolume < 0.5 ? Icons.volume_down : Icons.volume_up),
                      size: 20,
                      color: soundVolume == 0 ? AppConstants.errorRed : AppConstants.primaryIndigo,
                    ),
                    tooltip: soundVolume == 0 ? 'Unmute' : 'Mute',
                    onPressed: onToggleMute,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: AppConstants.primaryIndigo,
                        inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                        thumbColor: AppConstants.primaryIndigo,
                      ),
                      child: Slider(
                        value: soundVolume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: onVolumeChanged,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    alignment: Alignment.centerRight,
                    child: Text(
                      soundVolume == 0 ? 'Muted' : '${(soundVolume * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: soundVolume == 0 ? AppConstants.errorRed : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
