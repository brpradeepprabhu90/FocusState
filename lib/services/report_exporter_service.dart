import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/task.dart';

class ReportExporterService {
  static Future<bool> exportCsvReport({
    required BuildContext context,
    required List<Project> projects,
    required List<Task> tasks,
    required int currentStreak,
    required int dailyGoalPomodoros,
  }) async {
    try {
      final buffer = StringBuffer();

      // Header Banner
      buffer.writeln('FLOWSTATE PRODUCTIVITY & FOCUS REPORT');
      buffer.writeln('Generated Date,${DateTime.now().toIso8601String()}');
      buffer.writeln('Current Streak,${currentStreak} Days');
      buffer.writeln('Daily Focus Goal,$dailyGoalPomodoros Pomodoros');
      buffer.writeln();

      // Summary Table
      final completedTasks = tasks.where((t) => t.isCompleted).toList();
      final totalMinutes = tasks.fold<int>(0, (sum, t) => sum + (t.timeSpentSeconds ~/ 60));
      final totalPomodoros = tasks.fold<double>(0.0, (sum, t) => sum + t.completedPomodoros);

      buffer.writeln('--- SUMMARY METRICS ---');
      buffer.writeln('Total Tasks,${tasks.length}');
      buffer.writeln('Completed Tasks,${completedTasks.length}');
      buffer.writeln('Pending Tasks,${tasks.length - completedTasks.length}');
      buffer.writeln('Total Focus Time (Minutes),$totalMinutes');
      buffer.writeln('Total Completed Pomodoros,${totalPomodoros.toStringAsFixed(2)}');
      buffer.writeln();

      // Task Details Table
      buffer.writeln('--- TASK LOG DETAILS ---');
      buffer.writeln('Task Title,Project Name,Est Mins,Time Spent Mins,Completed Pomodoros,Est Pomodoros,Status,Completed Date');

      for (final task in tasks) {
        final proj = projects.firstWhere(
          (p) => p.id == task.projectId,
          orElse: () => Project(id: '0', name: 'General', color: Colors.grey),
        );

        final status = task.isCompleted ? 'Completed' : 'Pending';
        final completedDate = task.completedAt?.toIso8601String() ?? 'N/A';
        final titleClean = task.title.replaceAll('"', '""');
        final projClean = proj.name.replaceAll('"', '""');

        buffer.writeln('"$titleClean","$projClean",${task.durationMinutes},${task.timeSpentSeconds ~/ 60},${task.formattedCompletedPomodoros},${task.estimatedPomodoros},"$status","$completedDate"');
      }

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export CSV Focus Report',
        fileName: 'flowstate_weekly_report.csv',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(buffer.toString());
        return true;
      }
    } catch (e) {
      debugPrint('Error exporting CSV report: $e');
    }
    return false;
  }
}
