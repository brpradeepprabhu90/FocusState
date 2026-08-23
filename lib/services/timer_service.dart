import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'timer_foreground', // id
    'Focus Timer', // name
    description: 'This channel is used for the focus timer.',
    importance: Importance.low, // low importance so it doesn't make a sound every second
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'timer_foreground',
      initialNotificationTitle: 'Focus Timer Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launcher_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

  Timer? timer;
  int secondsLeft = 0;
  int sessionDurationSeconds = 25 * 60;
  DateTime? targetEndTime;
  String taskTitle = "Focus Session";
  int estimatedPomodoros = 1;
  double completedPomodoros = 0.0;

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });

  service.on('startTimer').listen((event) async {
    final payload = event ?? {};
    
    // Check if we are resuming or starting fresh
    if (payload.containsKey('targetEndTimeMs')) {
      targetEndTime = DateTime.fromMillisecondsSinceEpoch(payload['targetEndTimeMs']);
      taskTitle = payload['taskTitle'] ?? taskTitle;
      estimatedPomodoros = payload['estimatedPomodoros'] ?? estimatedPomodoros;
      completedPomodoros = (payload['completedPomodoros'] as num?)?.toDouble() ?? completedPomodoros;
      sessionDurationSeconds = payload['sessionDurationSeconds'] ?? (25 * 60);
      
      final now = DateTime.now();
      secondsLeft = targetEndTime!.difference(now).inSeconds;
    } else {
      secondsLeft = payload['secondsLeft'] ?? payload['seconds'] ?? (25 * 60);
      sessionDurationSeconds = secondsLeft;
      taskTitle = payload['taskTitle'] ?? "Focus Session";
      estimatedPomodoros = payload['estimatedPomodoros'] ?? 1;
      completedPomodoros = (payload['completedPomodoros'] as num?)?.toDouble() ?? 0.0;
      targetEndTime = DateTime.now().add(Duration(seconds: secondsLeft));
    }

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();
      secondsLeft = targetEndTime!.difference(now).inSeconds;

      if (secondsLeft <= 0) {
        completedPomodoros += 1.0;
        targetEndTime = DateTime.now().add(Duration(seconds: sessionDurationSeconds));
        secondsLeft = sessionDurationSeconds;

        // Trigger high priority notification for completion
        const AndroidNotificationChannel completionChannel = AndroidNotificationChannel(
          'timer_completion',
          'Timer Completion Alerts',
          importance: Importance.high,
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(completionChannel);

        final pomodoroLabel = completedPomodoros == completedPomodoros.toInt()
            ? completedPomodoros.toInt().toString()
            : completedPomodoros.toStringAsFixed(1);

        flutterLocalNotificationsPlugin.show(
          id: 889,
          title: 'Pomodoro Completed!',
          body: 'Pomodoro $pomodoroLabel completed for "$taskTitle". Next session started!',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'timer_completion',
              'Timer Completion Alerts',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'launcher_icon',
            ),
          ),
        );
        
        service.invoke('timerCompleted', {
          'completedPomodoros': completedPomodoros,
        });
      }

      String m = (secondsLeft.abs() ~/ 60).toString().padLeft(2, '0');
      String s = (secondsLeft.abs() % 60).toString().padLeft(2, '0');
      String timeString = '$m:$s';

      final pomodoroLabel = completedPomodoros == completedPomodoros.toInt()
          ? completedPomodoros.toInt().toString()
          : completedPomodoros.toStringAsFixed(1);

      flutterLocalNotificationsPlugin.show(
        id: 888,
        title: 'Focus: $taskTitle',
        body: 'Time left: $timeString | Pomodoros: $pomodoroLabel/$estimatedPomodoros',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_foreground',
            'Focus Timer',
            icon: 'launcher_icon',
            ongoing: true,
          ),
        ),
      );

      service.invoke(
        'update',
        {
          "secondsLeft": secondsLeft,
          "completedPomodoros": completedPomodoros,
          "isOvertime": false,
        },
      );
    });
  });

  service.on('pauseTimer').listen((event) {
    timer?.cancel();
  });
}
