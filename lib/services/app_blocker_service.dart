import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/app_info.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class AppBlockerService {
  static const _channel = MethodChannel(AppConstants.blockerMethodChannel);
  final StorageService _storageService = StorageService();

  Future<List<AppInfo>> loadInstalledApps() async {
    if (!Platform.isAndroid) return AppConstants.defaultAppsToBlock;
    try {
      final savedStates = await _storageService.loadBlockedAppStates();
      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      if (apps != null && apps.isNotEmpty) {
        return apps.map((app) {
          final String pkg = app['packageName'] as String;
          final String name = app['name'] as String;
          
          final bool isBlocked;
          if (savedStates.containsKey(pkg)) {
            isBlocked = savedStates[pkg]!;
          } else {
            final defaultApp = AppConstants.defaultAppsToBlock.where((a) => a.packageName == pkg).firstOrNull;
            isBlocked = defaultApp != null ? defaultApp.isBlocked : true;
          }

          return AppInfo(
            name: name,
            packageName: pkg,
            icon: Icons.android,
            isBlocked: isBlocked,
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
      if (enable && blockedPackages.isNotEmpty) {
        await _channel.invokeMethod('startBlocking', {
          'packages': blockedPackages,
          'blockedApps': blockedPackages,
        });
      } else {
        await _channel.invokeMethod('stopBlocking');
      }
    } catch (e) {
      debugPrint('Failed to update native blocker: $e');
    }
  }

  Future<bool> checkPermissions() async {
    return checkAccessibilityPermission();
  }

  Future<bool> checkAccessibilityPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool hasPermission = await _channel.invokeMethod('checkAccessibilityService');
      return hasPermission;
    } catch (e) {
      debugPrint('Error checking accessibility permission: $e');
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }
  }

  Future<bool> checkBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool isIgnoring = await _channel.invokeMethod('checkBatteryOptimization');
      return isIgnoring;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  Future<void> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Error requesting battery optimization: $e');
    }
  }

  Future<bool> checkNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool granted = await _channel.invokeMethod('checkNotificationPermission');
      return granted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }
}
