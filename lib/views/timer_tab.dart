import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../constants/app_constants.dart';
import '../models/app_info.dart';
import '../models/app_settings.dart';
import '../models/task.dart';

class TimerTab extends StatefulWidget {
  final Task? activeTask;
  final bool isTimerRunning;
  final AppSettings settings;
  final VoidCallback onPauseTimer;
  final VoidCallback onResumeTimer;
  final VoidCallback onCompleteTask;
  final VoidCallback onSelectTaskPrompt;
  final VoidCallback onSaveSettings;

  const TimerTab({
    Key? key,
    required this.activeTask,
    required this.isTimerRunning,
    required this.settings,
    required this.onPauseTimer,
    required this.onResumeTimer,
    required this.onCompleteTask,
    required this.onSelectTaskPrompt,
    required this.onSaveSettings,
  }) : super(key: key);

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> with WidgetsBindingObserver {
  static const _channel = MethodChannel(AppConstants.blockerMethodChannel);

  int _secondsLeft = 25 * 60;
  bool _hasNotifiedEnd = false;
  String _currentStage = 'Flow';
  DateTime? _lastTickTime;
  bool _isRestoring = false;
  Timer? _desktopTimer;
  StreamSubscription<Map<String, dynamic>?>? _serviceSubscription;
  StreamSubscription<Map<String, dynamic>?>? _completionSubscription;

  late bool _isAppBlockerEnabled;
  late List<AppInfo> _appsToBlock;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String _selectedSound = 'None';
  double _soundVolume = 0.7;
  double _preMuteVolume = 0.7;

  static const Map<String, String> _soundAssets = {
    'Monsoon Breath': 'sounds/Monsoon_Breath.wav',
    'Morning at the Ghat': 'sounds/Morning_at_the_Ghat.wav',
    'The Breathing Tide': 'sounds/The_Breathing_Tide.wav',
  };

  @override
  void initState() {
    super.initState();
    _isAppBlockerEnabled = widget.settings.defaultAppBlockerEnabled;
    _appsToBlock = List.from(AppConstants.defaultAppsToBlock);

    WidgetsBinding.instance.addObserver(this);
    _loadInstalledApps();
    
    if (Platform.isAndroid || Platform.isIOS) {
      _serviceSubscription = FlutterBackgroundService().on('update').listen((event) {
        if (!mounted || event == null) return;
        setState(() {
          _secondsLeft = event['secondsLeft'] ?? _secondsLeft;
          _hasNotifiedEnd = event['hasNotifiedCompletion'] ?? false;
          if (widget.activeTask != null && widget.isTimerRunning) {
            final now = DateTime.now();
            if (_lastTickTime != null) {
              final elapsedSinceLastTick = now.difference(_lastTickTime!).inSeconds;
              if (elapsedSinceLastTick > 0 && elapsedSinceLastTick < 5) {
                 widget.activeTask!.timeSpentSeconds += elapsedSinceLastTick;
              }
            }
            _lastTickTime = now;
          }
        });
      });

      _completionSubscription = FlutterBackgroundService().on('timerCompleted').listen((event) {
        if (!mounted) return;
        if (widget.settings.hapticFeedbackEnabled) {
          HapticFeedback.heavyImpact();
        }
        if (widget.activeTask != null) {
          widget.activeTask!.completedPomodoros++;
        }
        _triggerCompletionNotification();
      });
    }

    _restorePersistedTimer();
  }

  Future<void> _saveTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_timer_running', widget.isTimerRunning);
      await prefs.setInt('seconds_left', _secondsLeft);
    } catch (e) {
      debugPrint('Error saving timer state: $e');
    }
  }

  Future<void> _clearTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_timer_running', false);
      await prefs.remove('seconds_left');
    } catch (e) {
      debugPrint('Error clearing timer state: $e');
    }
  }

  Future<void> _restorePersistedTimer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool wasRunning = prefs.getBool('is_timer_running') ?? false;
      final int? savedSeconds = prefs.getInt('seconds_left');

      if (savedSeconds != null) {
        setState(() {
          _secondsLeft = savedSeconds;
        });
      }

      if (wasRunning) {
        _isRestoring = true;
        if (mounted) {
          if (!widget.isTimerRunning) {
            widget.onResumeTimer();
          } else {
            _startTimer();
          }
        }
      }
    } catch (e) {
      debugPrint('Error restoring timer: $e');
      _resetTimerForTask();
    }
  }

  Future<void> _loadInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      if (apps != null && apps.isNotEmpty) {
        setState(() {
          _appsToBlock = apps.map((app) {
            final String pkg = app['packageName'] as String;
            final String name = app['name'] as String;
            final defaultApp = AppConstants.defaultAppsToBlock.where((a) => a.packageName == pkg).firstOrNull;
            return AppInfo(
              name: name,
              packageName: pkg,
              icon: Icons.android,
              isBlocked: defaultApp != null ? defaultApp.isBlocked : true,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Failed to load installed apps: $e');
    }
  }

  @override
  void didUpdateWidget(covariant TimerTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeTask?.id != oldWidget.activeTask?.id ||
        widget.settings.defaultPomodoroMinutes != oldWidget.settings.defaultPomodoroMinutes) {
      _resetTimerForTask();
    } else if (widget.isTimerRunning != oldWidget.isTimerRunning) {
      if (widget.isTimerRunning) {
        _startTimer();
      } else {
        if (Platform.isAndroid || Platform.isIOS) {
          FlutterBackgroundService().invoke('pauseTimer');
        } else {
          _desktopTimer?.cancel();
        }
        _saveTimerState();
        _updateNativeAppBlocker(false);
        _stopAmbientSound();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isTimerRunning) {
      _updateNativeAppBlocker(true);
    } else if (state == AppLifecycleState.paused && widget.isTimerRunning) {
      _saveTimerState();
    }
  }

  Future<void> _playAmbientSound() async {
    if (_selectedSound != 'None' && _soundAssets.containsKey(_selectedSound)) {
      try {
        await _audioPlayer.setVolume(_soundVolume);
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(_soundAssets[_selectedSound]!));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    } else {
      await _stopAmbientSound();
    }
  }

  Future<void> _stopAmbientSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  void _toggleMute() {
    setState(() {
      if (_soundVolume > 0) {
        _preMuteVolume = _soundVolume;
        _soundVolume = 0.0;
      } else {
        _soundVolume = _preMuteVolume > 0 ? _preMuteVolume : 0.7;
      }
    });
    _audioPlayer.setVolume(_soundVolume);
  }

  void _resetTimerForTask() {
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterBackgroundService().invoke('pauseTimer');
    } else {
      _desktopTimer?.cancel();
    }
    _hasNotifiedEnd = false;
    _clearTimerState();

    if (widget.activeTask != null) {
      setState(() {
        _secondsLeft = widget.activeTask!.durationMinutes * 60;
        _currentStage = 'Flow';
      });
      if (widget.isTimerRunning) {
        _startTimer();
      }
    } else {
      setState(() {
        _secondsLeft = widget.settings.defaultPomodoroMinutes * 60;
        _currentStage = 'Flow';
      });
      if (widget.isTimerRunning) {
        widget.onPauseTimer();
      }
    }
  }

  void _stopTimer() {
    if (widget.activeTask != null) {
      final totalSeconds = widget.activeTask!.durationMinutes * 60;
      if (_secondsLeft < totalSeconds && _secondsLeft > 0) {
        widget.activeTask!.interruptedPomodoros++;
      }
    }
    if (widget.isTimerRunning) {
      widget.onPauseTimer();
    }
    _resetTimerForTask();
  }

  Future<void> _updateNativeAppBlocker(bool active) async {
    if (!_isAppBlockerEnabled) {
      active = false;
    }

    final blockedPackages =
        _appsToBlock.where((app) => app.isBlocked).map((app) => app.packageName).toList();

    try {
      if (active) {
        // First check if Accessibility Service is enabled
        final isServiceEnabled = await _channel.invokeMethod<bool>('checkAccessibilityService');
        
        if (isServiceEnabled == true) {
          await _channel.invokeMethod('startBlocking', {'packages': blockedPackages});
        } else {
          // Pause timer if running because they need to leave the app to enable settings
          if (widget.isTimerRunning) {
             widget.onPauseTimer();
          }
          
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.security, color: AppConstants.warningAmber),
                    SizedBox(width: 8),
                    Text('Permission Required'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'To block distracting apps during focus sessions, FlowState requires Accessibility Service permission.',
                      ),
                      SizedBox(height: 12),
                      Text(
                        '⚠️ If Android shows "Restricted setting":',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.warningAmber),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Because this APK was installed manually:\n'
                        '1. Open Phone Settings -> Apps -> FlowState.\n'
                        '2. Tap the 3 dots (⋮) in the top-right corner.\n'
                        '3. Select "Allow restricted settings".\n'
                        '4. Then return to Accessibility settings to turn on FlowState.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryIndigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _channel.invokeMethod('openAccessibilitySettings');
                      Navigator.pop(ctx);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        await _channel.invokeMethod('stopBlocking');
      }
    } catch (e) {
      debugPrint('Native MethodChannel (Android only): $e');
    }
  }

  void _triggerCompletionNotification() {
    if (!widget.settings.notificationsEnabled) return;

    String title = 'Focus Time Finished!';
    String content = 'Pomodoro timer reached 00:00 for "${widget.activeTask?.title ?? "Focus Task"}".\n\nTimer will now count into negative overtime until you end it.';
    
    if (widget.activeTask != null) {
      if (widget.activeTask!.completedPomodoros > widget.activeTask!.estimatedPomodoros) {
        title = 'Overtime Alert!';
        content = 'You have exceeded your estimated pomodoros (${widget.activeTask!.estimatedPomodoros}) for "${widget.activeTask!.title}". Great dedication, but remember to rest!';
      } else if (widget.activeTask!.completedPomodoros == widget.activeTask!.estimatedPomodoros) {
        title = 'Task Goal Reached!';
        content = 'Congratulations! You successfully completed all ${widget.activeTask!.estimatedPomodoros} estimated pomodoros for "${widget.activeTask!.title}".';
      } else {
        title = 'Pomodoro Completed!';
        content = 'Great job! You have completed ${widget.activeTask!.completedPomodoros} out of ${widget.activeTask!.estimatedPomodoros} pomodoros for "${widget.activeTask!.title}".';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppConstants.warningAmber),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(content),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.timer, size: 18),
            label: const Text('Continue Overtime'),
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.accentEmerald),
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      ),
    );
  }

  void _startTimer() {
    _updateNativeAppBlocker(true);
    _playAmbientSound();

    _lastTickTime = DateTime.now();
    
    // Save state for persistence
    _saveTimerState();

    if (Platform.isAndroid || Platform.isIOS) {
      FlutterBackgroundService().startService();
      
      if (!_isRestoring) {
        FlutterBackgroundService().invoke('startTimer', {
          'secondsLeft': _secondsLeft,
          'taskTitle': widget.activeTask?.title ?? "Focus Session",
          'estimatedPomodoros': widget.activeTask?.estimatedPomodoros ?? 1,
          'completedPomodoros': widget.activeTask?.completedPomodoros ?? 0,
        });
      } else {
        _isRestoring = false;
      }
    } else {
      _desktopTimer?.cancel();
      _desktopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _secondsLeft--;
          if (_secondsLeft <= 0 && !_hasNotifiedEnd) {
            _hasNotifiedEnd = true;
            if (widget.settings.hapticFeedbackEnabled) {
              HapticFeedback.heavyImpact();
            }
            if (widget.activeTask != null) {
              widget.activeTask!.completedPomodoros++;
            }
            _triggerCompletionNotification();
          }
          if (widget.activeTask != null && widget.isTimerRunning) {
            final now = DateTime.now();
            if (_lastTickTime != null) {
              final elapsedSinceLastTick = now.difference(_lastTickTime!).inSeconds;
              if (elapsedSinceLastTick > 0 && elapsedSinceLastTick < 5) {
                widget.activeTask!.timeSpentSeconds += elapsedSinceLastTick;
              }
            }
            _lastTickTime = now;
          }
        });
      });
      _isRestoring = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSubscription?.cancel();
    _completionSubscription?.cancel();
    _desktopTimer?.cancel();
    _stopAmbientSound();
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _timeString {
    final absSec = _secondsLeft.abs();
    final m = (absSec / 60).floor().toString().padLeft(2, '0');
    final s = (absSec % 60).toString().padLeft(2, '0');

    if (_secondsLeft < 0) {
      return '-$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.activeTask;
    final totalSeconds = (task?.durationMinutes ?? widget.settings.defaultPomodoroMinutes) * 60;
    final progress = totalSeconds > 0
        ? (_secondsLeft > 0 ? _secondsLeft / totalSeconds : 0.0)
        : 1.0;

    final isOvertime = _secondsLeft < 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppConstants.primaryIndigo,
            labelColor: AppConstants.accentIndigoSoft,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.timer, size: 16), SizedBox(width: 8), Text('Timer')],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.shield, size: 16), SizedBox(width: 8), Text('Block Apps')],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // SUB-TAB 1: TIMER CONTROLS
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
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
                                  : (widget.isTimerRunning ? AppConstants.accentEmerald : Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOvertime ? 'OVERTIME IN PROGRESS' : 'ACTIVE FOCUS TASK',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isOvertime ? AppConstants.errorRed : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    task?.title ?? 'Default Focus Session (${widget.settings.defaultPomodoroMinutes}m)',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (task != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Pomodoros: ${task.completedPomodoros} / ${task.estimatedPomodoros}',
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
                            if (task == null)
                              TextButton.icon(
                                icon: const Icon(Icons.touch_app),
                                label: const Text('Pick Task'),
                                onPressed: widget.onSelectTaskPrompt,
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
                                  isOvertime ? AppConstants.errorRed : AppConstants.primaryIndigo,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _timeString,
                                  style: TextStyle(
                                    fontSize: isOvertime ? 44 : 50,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: isOvertime
                                        ? AppConstants.errorRed
                                        : (isDark ? Colors.white : AppConstants.darkBackground),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOvertime
                                        ? AppConstants.errorRed.withOpacity(0.2)
                                        : AppConstants.primaryIndigo.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOvertime ? Icons.warning : Icons.bolt,
                                        size: 14,
                                        color: isOvertime ? AppConstants.errorRed : AppConstants.accentIndigoSoft,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOvertime ? 'OVERTIME WORK' : _currentStage.toUpperCase(),
                                        style: TextStyle(
                                          color: isOvertime ? AppConstants.errorRed : AppConstants.accentIndigoSoft,
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
                                widget.isTimerRunning ? Icons.pause : Icons.play_arrow,
                                size: 24),
                            label: Text(
                                widget.isTimerRunning ? 'Pause' : 'Play',
                                style: const TextStyle(fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isTimerRunning
                                  ? AppConstants.warningAmber
                                  : AppConstants.accentEmerald,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              if (widget.isTimerRunning) {
                                widget.onPauseTimer();
                              } else {
                                widget.onResumeTimer();
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
                            onPressed: _stopTimer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ambient Sound Selector Card with Volume Slider
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppConstants.darkSurface : AppConstants.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedSound != 'None'
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
                                  value: _selectedSound,
                                  underline: const SizedBox(),
                                  isDense: true,
                                  items: const [
                                    DropdownMenuItem(value: 'None', child: Text('🔇 None')),
                                    DropdownMenuItem(value: 'Monsoon Breath', child: Text('🌧️ Monsoon Breath')),
                                    DropdownMenuItem(value: 'Morning at the Ghat', child: Text('🌅 Morning at the Ghat')),
                                    DropdownMenuItem(value: 'The Breathing Tide', child: Text('🌊 The Breathing Tide')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedSound = val;
                                      });
                                      if (widget.isTimerRunning) {
                                        _playAmbientSound();
                                      } else {
                                        _stopAmbientSound();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (_selectedSound != 'None') ...[
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
                                        _soundVolume == 0
                                            ? Icons.volume_off
                                            : (_soundVolume < 0.5 ? Icons.volume_down : Icons.volume_up),
                                        size: 20,
                                        color: _soundVolume == 0 ? AppConstants.errorRed : AppConstants.primaryIndigo,
                                      ),
                                      tooltip: _soundVolume == 0 ? 'Unmute' : 'Mute',
                                      onPressed: _toggleMute,
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
                                          value: _soundVolume,
                                          min: 0.0,
                                          max: 1.0,
                                          onChanged: (newVol) {
                                            setState(() {
                                              _soundVolume = newVol;
                                              if (newVol > 0) {
                                                _preMuteVolume = newVol;
                                              }
                                            });
                                            _audioPlayer.setVolume(newVol);
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 44,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _soundVolume == 0 ? 'Muted' : '${(_soundVolume * 100).round()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _soundVolume == 0 ? AppConstants.errorRed : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // SUB-TAB 2: BLOCKED APPS CONFIGURATION
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select apps to block', style: TextStyle(color: Colors.grey)),
                          Row(
                            children: [
                              TextButton(
                                onPressed: widget.isTimerRunning ? null : () {
                                  setState(() {
                                    for (var app in _appsToBlock) app.isBlocked = true;
                                  });
                                },
                                child: const Text('Block All'),
                              ),
                              TextButton(
                                onPressed: widget.isTimerRunning ? null : () {
                                  setState(() {
                                    for (var app in _appsToBlock) app.isBlocked = false;
                                  });
                                },
                                child: const Text('Allow All'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _appsToBlock.length,
                        itemBuilder: (context, index) {
                          final app = _appsToBlock[index];
                          return SwitchListTile(
                            title: Text(app.name),
                            subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            value: app.isBlocked,
                            activeColor: AppConstants.errorRed,
                            secondary: Icon(app.icon, color: app.isBlocked ? AppConstants.errorRed : AppConstants.accentEmerald),
                            onChanged: widget.isTimerRunning ? null : (val) {
                              setState(() {
                                app.isBlocked = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
