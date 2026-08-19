import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/app_blocker_service.dart';
import '../constants/app_constants.dart';

class SettingsModal extends StatefulWidget {
  final AppSettings settings;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final VoidCallback onRequestBackgroundUsage;
  final Function(AppSettings) onSaveSettings;

  const SettingsModal({
    Key? key,
    required this.settings,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onRequestBackgroundUsage,
    required this.onSaveSettings,
  }) : super(key: key);

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final AppBlockerService _appBlockerService = AppBlockerService();

  late TextEditingController _pomodoroController;
  late bool _blockerDefault;
  late bool _hapticEnabled;
  late bool _notificationsEnabled;
  late ThemeMode _tempTheme;

  bool _accessibilityGranted = false;
  bool _batteryExemptGranted = false;
  bool _notificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _pomodoroController = TextEditingController(
      text: widget.settings.defaultPomodoroMinutes.toString(),
    );
    _blockerDefault = widget.settings.defaultAppBlockerEnabled;
    _hapticEnabled = widget.settings.hapticFeedbackEnabled;
    _notificationsEnabled = widget.settings.notificationsEnabled;
    _tempTheme = widget.currentThemeMode;

    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final acc = await _appBlockerService.checkAccessibilityPermission();
    final bat = await _appBlockerService.checkBatteryOptimization();
    final not = await _appBlockerService.checkNotificationPermission();

    if (mounted) {
      setState(() {
        _accessibilityGranted = acc;
        _batteryExemptGranted = bat;
        _notificationPermissionGranted = not;
      });
    }
  }

  Future<void> _exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final data = <String, dynamic>{};
      for (final key in keys) {
        data[key] = prefs.get(key);
      }
      final jsonString = jsonEncode(data);

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: 'flowstate_backup.json',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup exported successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting backup: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        for (final key in data.keys) {
          final value = data[key];
          if (value is String) {
            await prefs.setString(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is List) {
            await prefs.setStringList(key, value.cast<String>());
          }
        }
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Import Successful'),
              content: const Text('Your backup has been restored. Please restart the app for changes to take effect.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing backup: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.tune, color: Color(0xFF818CF8), size: 24),
                  SizedBox(width: 8),
                  Text('App Preferences & Theme',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // THEME MODE SELECTION
          const Text('App Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {_tempTheme},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              setState(() {
                _tempTheme = newSelection.first;
              });
              widget.onThemeChanged(newSelection.first);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _pomodoroController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Default Pomodoro Time (Minutes)',
              prefixIcon: const Icon(Icons.timer_outlined, color: Color(0xFF818CF8)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            secondary: const Icon(Icons.block, color: Color(0xFFEF4444)),
            title: const Text('App Blocker Enabled by Default'),
            subtitle: const Text('Automatically block distracting apps on timer start'),
            value: _blockerDefault,
            activeColor: const Color(0xFF6366F1),
            onChanged: (val) {
              setState(() {
                _blockerDefault = val;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration, color: Color(0xFF6366F1)),
            title: const Text('Haptic Feedback (Vibration)'),
            subtitle: const Text('Vibrate when a timer completes'),
            value: _hapticEnabled,
            activeColor: const Color(0xFF6366F1),
            onChanged: (val) {
              setState(() {
                _hapticEnabled = val;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: Color(0xFF10B981)),
            title: const Text('Notifications'),
            subtitle: const Text('Show alerts when tasks complete or exceed'),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF6366F1),
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
          const Divider(),

          // SYSTEM PERMISSIONS MANAGEMENT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('System Permissions & Services',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh permission status',
                onPressed: _refreshPermissions,
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 1. Accessibility Service
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.block,
              color: _accessibilityGranted ? AppConstants.accentEmerald : Colors.amber,
            ),
            title: const Text('App Blocker Accessibility Service'),
            subtitle: Text(_accessibilityGranted
                ? 'Permission granted. Active app blocking ready.'
                : 'Action required to intercept blocked apps.'),
            trailing: OutlinedButton(
              onPressed: () async {
                await _appBlockerService.openAccessibilitySettings();
              },
              child: Text(_accessibilityGranted ? 'Manage' : 'Grant'),
            ),
          ),

          // 2. Battery Exemption
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.battery_charging_full,
              color: _batteryExemptGranted ? AppConstants.accentEmerald : Colors.amber,
            ),
            title: const Text('Background Execution / Battery Limit'),
            subtitle: Text(_batteryExemptGranted
                ? 'Battery optimization exempt. Timer runs reliably.'
                : 'Allow background execution without OS kill.'),
            trailing: OutlinedButton(
              onPressed: () async {
                await _appBlockerService.requestBatteryOptimization();
              },
              child: Text(_batteryExemptGranted ? 'Manage' : 'Grant'),
            ),
          ),

          // 3. System Notifications
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.notifications_active,
              color: _notificationPermissionGranted ? AppConstants.accentEmerald : Colors.amber,
            ),
            title: const Text('System Notifications'),
            subtitle: Text(_notificationPermissionGranted
                ? 'Notifications active.'
                : 'Permission disabled in system settings.'),
            trailing: OutlinedButton(
              onPressed: () async {
                await _appBlockerService.openNotificationSettings();
              },
              child: Text(_notificationPermissionGranted ? 'Manage' : 'Grant'),
            ),
          ),

          const Divider(),
          const Text('Data Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Backup'),
                  onPressed: _exportData,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Import Backup'),
                  onPressed: _importData,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Preferences', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onSaveSettings(
                  AppSettings(
                    defaultPomodoroMinutes: int.tryParse(_pomodoroController.text) ?? 25,
                    defaultAppBlockerEnabled: _blockerDefault,
                    hapticFeedbackEnabled: _hapticEnabled,
                    notificationsEnabled: _notificationsEnabled,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Settings updated successfully!'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
