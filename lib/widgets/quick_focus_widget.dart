import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/task.dart';

class QuickFocusWidget extends StatelessWidget {
  final Task? activeTask;
  final bool isTimerRunning;
  final VoidCallback onQuickStartFocus;

  const QuickFocusWidget({
    Key? key,
    required this.activeTask,
    required this.isTimerRunning,
    required this.onQuickStartFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTimerRunning
              ? [AppConstants.accentEmerald, AppConstants.primaryIndigo]
              : [AppConstants.primaryIndigo, AppConstants.accentIndigoSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isTimerRunning ? AppConstants.accentEmerald : AppConstants.primaryIndigo).withValues(alpha: 0.3),
            blurRadius: 10,
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
            child: Icon(
              isTimerRunning ? Icons.play_arrow : Icons.bolt,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTimerRunning ? 'Focus Session Active' : 'Quick Start Focus',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTimerRunning
                      ? (activeTask?.title ?? '25m Focus Timer')
                      : 'Start instant 25m session with 1 tap',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(isTimerRunning ? Icons.timer : Icons.play_arrow, size: 16),
            label: Text(isTimerRunning ? 'View' : 'Start', style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isTimerRunning ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: onQuickStartFocus,
          ),
        ],
      ),
    );
  }
}
