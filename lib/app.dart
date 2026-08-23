import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'views/home_screen.dart';
import 'services/storage_service.dart';

class FlowStateApp extends StatefulWidget {
  const FlowStateApp({Key? key}) : super(key: key);

  @override
  State<FlowStateApp> createState() => _FlowStateAppState();
}

class _FlowStateAppState extends State<FlowStateApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await _storageService.loadThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _storageService.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // LIGHT THEME DESIGN
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppConstants.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppConstants.primaryLightIndigo,
          secondary: AppConstants.accentEmerald,
          surface: AppConstants.lightSurface,
        ),
        cardColor: AppConstants.lightSurface,
        useMaterial3: true,
      ),

      // DARK THEME DESIGN
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryIndigo,
          secondary: AppConstants.accentEmerald,
          surface: AppConstants.darkSurface,
        ),
        cardColor: AppConstants.darkSurface,
        useMaterial3: true,
      ),
      home: MainHomeScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateThemeMode,
      ),
    );
  }
}
