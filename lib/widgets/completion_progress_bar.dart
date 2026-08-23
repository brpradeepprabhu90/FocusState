import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CompletionProgressBar extends StatelessWidget {
  final double completionRatio;

  const CompletionProgressBar({
    Key? key,
    required this.completionRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.pie_chart, size: 18, color: AppConstants.accentIndigoSoft),
                  SizedBox(width: 8),
                  Text('Task Completion Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${(completionRatio * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.accentEmerald)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRatio,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.accentEmerald),
            ),
          ),
        ],
      ),
    );
  }
}
