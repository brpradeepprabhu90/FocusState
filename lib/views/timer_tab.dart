import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../constants/app_constants.dart';
import '../models/app_info.dart';
import '../models/app_settings.dart';
import '../models/task.dart';

// Services
import '../services/audio_service.dart';
import '../services/app_blocker_service.dart';

// Widgets
import '../widgets/timer_display.dart';
import '../widgets/ambient_sound_selector.dart';
import '../widgets/app_blocker_list.dart';

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
  final AudioService _audioService = AudioService();
  final AppBlockerService _appBlockerService = AppBlockerService();

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

  String _selectedSound = 'None';
  double _soundVolume = 0.7;
  double _preMuteVolume = 0.7;

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
    final apps = await _appBlockerService.loadInstalledApps();
    if (apps.isNotEmpty && mounted) {
      setState(() {
        _appsToBlock = apps;
      });
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
        _audioService.stopAmbientSound();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSubscription?.cancel();
    _completionSubscription?.cancel();
    _desktopTimer?.cancel();
    _audioService.stopAmbientSound();
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_hasNotifiedEnd && !widget.isTimerRunning) {
        _triggerCompletionNotification();
        _hasNotifiedEnd = false;
      }
      
      if (widget.isTimerRunning && _isAppBlockerEnabled) {
        _appBlockerService.checkPermissions().then((hasPermission) {
          if (!hasPermission && mounted) {
            _showPermissionDialog();
            widget.onPauseTimer();
          }
        });
      }
    }
  }

  void _resetTimerForTask() {
    setState(() {
      _secondsLeft = (widget.activeTask?.durationMinutes ?? widget.settings.defaultPomodoroMinutes) * 60;
      _hasNotifiedEnd = false;
      _currentStage = 'Flow';
    });
    _clearTimerState();
  }

  Future<void> _updateNativeAppBlocker(bool enable) async {
    if (Platform.isAndroid) {
      await _appBlockerService.updateNativeAppBlocker(enable, _appsToBlock);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'To forcefully block apps during your flow state, this app requires Accessibility Service permissions.\n\n'
            'Please enable "FlowState App Blocker" in System Accessibility Settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel / Use Timer Only'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _appBlockerService.openAccessibilitySettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startTimer() async {
    setState(() {
      _lastTickTime = DateTime.now();
    });

    if (_isAppBlockerEnabled) {
      bool hasPermission = await _appBlockerService.checkPermissions();
      if (!hasPermission) {
        _showPermissionDialog();
        widget.onPauseTimer();
        return;
      }
      _updateNativeAppBlocker(true);
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final service = FlutterBackgroundService();
      var isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
      }
      
      service.invoke('startTimer', {
        'seconds': _secondsLeft,
        'taskTitle': widget.activeTask?.title ?? 'Default Focus Session',
        'isRestoring': _isRestoring,
      });
      _isRestoring = false;
    } else {
      _desktopTimer?.cancel();
      _desktopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _secondsLeft--;
            if (widget.activeTask != null) {
              widget.activeTask!.timeSpentSeconds++;
            }
            if (_secondsLeft <= 0 && !_hasNotifiedEnd) {
              _hasNotifiedEnd = true;
              if (widget.activeTask != null) {
                widget.activeTask!.completedPomodoros++;
              }
              _triggerCompletionNotification();
            }
          });
          _saveTimerState();
        }
      });
    }

    _saveTimerState();
    _audioService.playAmbientSound(_selectedSound, _soundVolume);
  }

  void _stopTimer() {
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterBackgroundService().invoke('stopTimer');
    } else {
      _desktopTimer?.cancel();
    }
    _resetTimerForTask();
    widget.onPauseTimer();
    _updateNativeAppBlocker(false);
    _audioService.stopAmbientSound();
  }

  void _triggerCompletionNotification() {
    widget.onCompleteTask();
  }

  void _handleSoundSelected(String? val) {
    if (val != null) {
      setState(() {
        _selectedSound = val;
      });
      if (widget.isTimerRunning) {
        _audioService.playAmbientSound(_selectedSound, _soundVolume);
      } else {
        _audioService.stopAmbientSound();
      }
    }
  }

  void _handleVolumeChanged(double newVol) {
    setState(() {
      _soundVolume = newVol;
      if (newVol > 0) {
        _preMuteVolume = newVol;
      }
    });
    _audioService.setVolume(newVol);
  }

  void _handleToggleMute() {
    setState(() {
      if (_soundVolume > 0) {
        _soundVolume = 0;
      } else {
        _soundVolume = _preMuteVolume;
      }
    });
    _audioService.setVolume(_soundVolume);
  }

  void _handleAppToggled(int index) {
    setState(() {
      _appsToBlock[index].isBlocked = !_appsToBlock[index].isBlocked;
    });
  }

  void _handleBlockAll() {
    setState(() {
      for (var app in _appsToBlock) app.isBlocked = true;
    });
  }

  void _handleAllowAll() {
    setState(() {
      for (var app in _appsToBlock) app.isBlocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      TimerDisplay(
                        activeTask: widget.activeTask,
                        isTimerRunning: widget.isTimerRunning,
                        settings: widget.settings,
                        secondsLeft: _secondsLeft,
                        currentStage: _currentStage,
                        onSelectTaskPrompt: widget.onSelectTaskPrompt,
                        onPauseTimer: widget.onPauseTimer,
                        onResumeTimer: widget.onResumeTimer,
                        onStopTimer: _stopTimer,
                      ),
                      const SizedBox(height: 20),
                      AmbientSoundSelector(
                        selectedSound: _selectedSound,
                        soundVolume: _soundVolume,
                        onSoundSelected: _handleSoundSelected,
                        onVolumeChanged: _handleVolumeChanged,
                        onToggleMute: _handleToggleMute,
                      ),
                    ],
                  ),
                ),

                // SUB-TAB 2: BLOCKED APPS CONFIGURATION
                AppBlockerList(
                  appsToBlock: _appsToBlock,
                  isTimerRunning: widget.isTimerRunning,
                  onAppToggled: _handleAppToggled,
                  onBlockAll: _handleBlockAll,
                  onAllowAll: _handleAllowAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
