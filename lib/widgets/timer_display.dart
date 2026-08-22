import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/task.dart';

class TimerDisplay extends StatelessWidget {
  final Task? activeTask;
  final bool isTimerRunning;
  final AppSettings settings;
  final int secondsLeft;
  final String currentStage;
  final VoidCallback onSelectTaskPrompt;
  final VoidCallback onPauseTimer;
  final VoidCallback onResumeTimer;
  final VoidCallback onStopTimer;

  const TimerDisplay({
    Key? key,
    required this.activeTask,
    required this.isTimerRunning,
    required this.settings,
    required this.secondsLeft,
    required this.currentStage,
    required this.onSelectTaskPrompt,
    required this.onPauseTimer,
    required this.onResumeTimer,
    required this.onStopTimer,
  }) : super(key: key);

  String get _timeString {
    final absSeconds = secondsLeft.abs();
    final minutes = (absSeconds / 60).floor();
    final remainingSeconds = absSeconds % 60;
    final sign = secondsLeft < 0 ? '-' : '';
    return '$sign${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (activeTask?.durationMinutes ?? settings.defaultPomodoroMinutes) * 60;
    final progress = totalSeconds > 0
        ? (secondsLeft > 0 ? secondsLeft / totalSeconds : 0.0)
        : 1.0;

    final isOvertime = secondsLeft < 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Active Task Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                color: isOvertime
                    ? AppConstants.errorRed
                    : (isTimerRunning ? AppConstants.accentEmerald : Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTimerRunning ? 'FOCUS SESSION IN PROGRESS' : 'ACTIVE FOCUS TASK',
                      style: TextStyle(
                        fontSize: 11,
                        color: isTimerRunning ? AppConstants.accentEmerald : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      activeTask?.title ?? 'Default Focus Session (${settings.defaultPomodoroMinutes}m)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activeTask != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Pomodoros: ${activeTask!.formattedCompletedPomodoros} / ${activeTask!.estimatedPomodoros}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.accentIndigoSoft,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (activeTask == null)
                TextButton.icon(
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Pick Task'),
                  onPressed: onSelectTaskPrompt,
                )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Main Circle Timer
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isTimerRunning ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : AppConstants.darkBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isTimerRunning ? AppConstants.accentEmerald : AppConstants.primaryIndigo).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTimerRunning ? Icons.play_arrow : Icons.bolt,
                          size: 14,
                          color: isTimerRunning ? AppConstants.accentEmerald : AppConstants.accentIndigoSoft,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isTimerRunning ? 'IN FOCUS' : currentStage.toUpperCase(),
                          style: TextStyle(
                            color: isTimerRunning ? AppConstants.accentEmerald : AppConstants.accentIndigoSoft,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Timer Explicit Controls: PLAY/PAUSE, STOP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TOGGLE PLAY / PAUSE BUTTON
            ElevatedButton.icon(
              icon: Icon(
                  isTimerRunning ? Icons.pause : Icons.play_arrow,
                  size: 24),
              label: Text(
                  isTimerRunning ? 'Pause' : 'Play',
                  style: const TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTimerRunning
                    ? AppConstants.warningAmber
                    : AppConstants.accentEmerald,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (isTimerRunning) {
                  onPauseTimer();
                } else {
                  onResumeTimer();
                }
              },
            ),
            const SizedBox(width: 16),

            // STOP BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.stop, size: 24),
              label: const Text('Stop', style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onStopTimer,
            ),
          ],
        ),
      ],
    );
  }
}
