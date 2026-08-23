import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_blocker_service.dart';
import '../constants/app_constants.dart';

class PermissionOnboardingDialog extends StatefulWidget {
  final VoidCallback? onComplete;

  const PermissionOnboardingDialog({Key? key, this.onComplete}) : super(key: key);

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool completed = prefs.getBool('has_completed_permission_onboarding') ?? false;

    if (!completed && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: PermissionOnboardingDialog(
              onComplete: () {
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  State<PermissionOnboardingDialog> createState() => _PermissionOnboardingDialogState();
}

class _PermissionOnboardingDialogState extends State<PermissionOnboardingDialog>
    with WidgetsBindingObserver {
  final AppBlockerService _appBlockerService = AppBlockerService();

  bool _accessibilityGranted = false;
  bool _batteryExemptGranted = false;
  bool _notificationsGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);
    final isAcc = await _appBlockerService.checkAccessibilityPermission();
    final isBat = await _appBlockerService.checkBatteryOptimization();
    final isNot = await _appBlockerService.checkNotificationPermission();

    if (mounted) {
      setState(() {
        _accessibilityGranted = isAcc;
        _batteryExemptGranted = isBat;
        _notificationsGranted = isNot;
        _isLoading = false;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_permission_onboarding', true);
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _accessibilityGranted && _batteryExemptGranted && _notificationsGranted;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.primaryIndigo.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppConstants.primaryIndigo,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome to FlowState',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Permission Setup',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'To enable app blocking during focus timers and background timer execution, please grant the permissions below. You can also modify these anytime in Settings.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // ITEM 1: Accessibility Service
            _buildPermissionTile(
              title: 'App Blocker (Accessibility)',
              subtitle: 'Interacts with OS to intercept distracting apps when timer runs.',
              icon: Icons.block,
              isGranted: _accessibilityGranted,
              onTap: () async {
                await _appBlockerService.openAccessibilitySettings();
              },
            ),
            const SizedBox(height: 12),

            // ITEM 2: Battery Optimization Exemption
            _buildPermissionTile(
              title: 'Background Execution',
              subtitle: 'Keeps focus timer running smoothly when screen turns off.',
              icon: Icons.battery_charging_full,
              isGranted: _batteryExemptGranted,
              onTap: () async {
                await _appBlockerService.requestBatteryOptimization();
              },
            ),
            const SizedBox(height: 12),

            // ITEM 3: Notifications
            _buildPermissionTile(
              title: 'Notifications & Alerts',
              subtitle: 'Shows progress notifications and completion chimes.',
              icon: Icons.notifications_active,
              isGranted: _notificationsGranted,
              onTap: () async {
                await _appBlockerService.openNotificationSettings();
              },
            ),
          ],
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: allGranted ? AppConstants.accentEmerald : AppConstants.primaryIndigo,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _finishOnboarding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(allGranted ? Icons.check_circle : Icons.arrow_forward),
                const SizedBox(width: 8),
                Text(
                  allGranted ? 'All Set! Continue to App' : 'Continue to FlowState',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGranted
            ? AppConstants.accentEmerald.withOpacity(0.1)
            : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppConstants.accentEmerald.withOpacity(0.4)
              : Colors.amber.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isGranted ? AppConstants.accentEmerald : Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            Chip(
              avatar: const Icon(Icons.check, size: 14, color: Colors.white),
              label: const Text('Granted', style: TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: AppConstants.accentEmerald,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onTap,
              child: const Text('Enable', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
