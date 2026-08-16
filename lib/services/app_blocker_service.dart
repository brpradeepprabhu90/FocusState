import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_info.dart';
import '../constants/app_constants.dart';

class AppBlockerService {
  static const _channel = MethodChannel(AppConstants.blockerMethodChannel);

  Future<List<AppInfo>> loadInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      if (apps != null && apps.isNotEmpty) {
        return apps.map((app) {
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
      }
    } catch (e) {
      debugPrint('Failed to load installed apps: $e');
    }
    return [];
  }

  Future<void> updateNativeAppBlocker(bool enable, List<AppInfo> appsToBlock) async {
    try {
      final blockedPackages = appsToBlock.where((a) => a.isBlocked).map((a) => a.packageName).toList();
      await _channel.invokeMethod('updateBlockedApps', {
        'blockedApps': blockedPackages,
        'isEnabled': enable,
      });
    } catch (e) {
      debugPrint('Failed to update native blocker: $e');
    }
  }

  Future<bool> checkPermissions() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkAccessibilityService');
      return hasPermission;
    } catch (e) {
      debugPrint('Native MethodChannel (Android only): $e');
      return true; // Return true for non-Android platforms where blocking isn't needed
    }
  }
}
