import 'package:flutter/material.dart';
import '../models/app_settings.dart';

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
  late TextEditingController _pomodoroController;
  late bool _blockerDefault;
  late bool _hapticEnabled;
  late bool _notificationsEnabled;
  late ThemeMode _tempTheme;

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
          ListTile(
            leading: const Icon(Icons.battery_charging_full, color: Color(0xFF10B981)),
            title: const Text('Background Usage & Power'),
            subtitle: const Text('Allow uninterrupted execution in background'),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.flash_on, size: 16),
              label: const Text('Enable'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: widget.onRequestBackgroundUsage,
            ),
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
    );
  }
}
