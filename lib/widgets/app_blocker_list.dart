import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/app_info.dart';

class AppBlockerList extends StatelessWidget {
  final List<AppInfo> appsToBlock;
  final bool isTimerRunning;
  final ValueChanged<int> onAppToggled;
  final VoidCallback onBlockAll;
  final VoidCallback onAllowAll;

  const AppBlockerList({
    Key? key,
    required this.appsToBlock,
    required this.isTimerRunning,
    required this.onAppToggled,
    required this.onBlockAll,
    required this.onAllowAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (appsToBlock.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps_outage, size: 64, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'App Blocking Not Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature requires Android Accessibility Services, which are not available or not permitted on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
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
                    onPressed: isTimerRunning ? null : onBlockAll,
                    child: const Text('Block All'),
                  ),
                  TextButton(
                    onPressed: isTimerRunning ? null : onAllowAll,
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
            itemCount: appsToBlock.length,
            itemBuilder: (context, index) {
              final app = appsToBlock[index];
              return SwitchListTile(
                value: app.isBlocked,
                title: Text(app.name),
                subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                secondary: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(app.icon, color: AppConstants.primaryIndigo),
                ),
                activeColor: AppConstants.errorRed,
                onChanged: isTimerRunning
                    ? null
                    : (val) => onAppToggled(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
