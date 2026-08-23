import 'package:flutter/material.dart';

class AppInfo {
  final String name;
  final String packageName;
  final IconData icon;
  bool isBlocked;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.icon,
    this.isBlocked = true,
  });
}
