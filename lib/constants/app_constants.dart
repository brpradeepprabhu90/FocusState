import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppConstants {
  // Application Info
  static const String appName = 'FlowState';
  static const String blockerMethodChannel = 'com.flowstate/app_blocker';

  // Palette & Color Tokens
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryLightIndigo = Color(0xFF4F46E5);
  static const Color accentIndigoSoft = Color(0xFF818CF8);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;

  // Options & Dropdowns
  static const List<String> repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly'];

  // Default Apps List for Blocker
  static final List<AppInfo> defaultAppsToBlock = [
    AppInfo(name: 'Instagram', packageName: 'com.instagram.android', icon: Icons.camera_alt),
    AppInfo(name: 'YouTube', packageName: 'com.google.android.youtube', icon: Icons.play_circle_fill),
    AppInfo(name: 'TikTok', packageName: 'com.zhiliaoapp.musically', icon: Icons.music_note),
    AppInfo(name: 'Facebook', packageName: 'com.facebook.katana', icon: Icons.facebook),
    AppInfo(name: 'Twitter / X', packageName: 'com.twitter.android', icon: Icons.alternate_email),
    AppInfo(name: 'Reddit', packageName: 'com.reddit.frontpage', icon: Icons.forum),
    AppInfo(name: 'Chrome / Web', packageName: 'com.android.chrome', icon: Icons.public),
  ];
}
