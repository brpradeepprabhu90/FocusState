import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_state_app/controllers/app_controller.dart';
import 'package:flow_state_app/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppController Task Management Scenarios', () {
    late AppController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = AppController();
      await controller.init();
    });

    test('TC-TM-01 [Create Task] Positive Scenario', () {
      final task = Task(
        id: '1',
        title: 'Valid Task Title',
        estimatedPomodoros: 2,
        projectId: 'project-1',
        durationMinutes: 25,
      );

      controller.addNewTask(task);

      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Valid Task Title');
      expect(controller.tasks.first.estimatedPomodoros, 2);
    });

    test('TC-TM-02 [Complete Task] Positive Scenario', () {
      final task = Task(
        id: '2',
        title: 'Task To Complete',
        estimatedPomodoros: 1,
        projectId: 'project-1',
        durationMinutes: 25,
      );
      controller.addNewTask(task);

      controller.completeTaskDirectly(controller.tasks.first);

      expect(controller.tasks.first.isCompleted, true);
      expect(controller.tasks.first.completedAt, isNotNull);
    });

    test('TC-TM-03 [Edit Task] Positive Scenario', () {
      final task = Task(
        id: '3', 
        title: 'Old Title', 
        estimatedPomodoros: 1,
        projectId: 'project-1',
        durationMinutes: 25,
      );
      controller.addNewTask(task);

      final updatedTask = Task(
        id: '3', 
        title: 'New Title', 
        estimatedPomodoros: 5,
        projectId: 'project-1',
        durationMinutes: 25,
      );
      controller.updateTask(updatedTask);

      expect(controller.tasks.first.title, 'New Title');
      expect(controller.tasks.first.estimatedPomodoros, 5);
    });

    test('TC-PT-01 & 02 [Start/Pause Timer] Positive Scenario', () {
      final task = Task(
        id: '4', 
        title: 'Focus Task', 
        estimatedPomodoros: 1,
        projectId: 'project-1',
        durationMinutes: 25,
      );
      controller.addNewTask(task);

      controller.toggleTaskTimer(controller.tasks.first);
      expect(controller.isTimerRunning, true);
      expect(controller.activeTask?.id, '4');

      controller.pauseTimer();
      expect(controller.isTimerRunning, false);

      controller.resumeTimer();
      expect(controller.isTimerRunning, true);
    });

    test('TC-TM-06 [Zero Estimate] Negative Boundary Condition Handling', () {
      // Assuming UI prevents this, but testing model logic boundary
      final task = Task(
        id: '5',
        title: 'Invalid Estimate Task',
        estimatedPomodoros: -1, // Invalid
        projectId: 'project-1',
        durationMinutes: 25,
      );
      
      // We expect the app controller to still add it because validation is done in UI, 
      // but let's verify it gets added.
      controller.addNewTask(task);
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.estimatedPomodoros, -1);
    });
  });
}
