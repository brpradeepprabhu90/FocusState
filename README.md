# FlowState

FlowState is a high-performance productivity and focus application built with Flutter. It is designed to help users enter and maintain deep work states by combining Pomodoro-style task tracking with powerful, platform-specific distraction blockers and ambient focus sounds.

## Core Features

- **Robust Pomodoro Timer**: Track your focused work sessions with estimated vs. actual pomodoros. Built to run perfectly in the background or when the app is closed.
- **Persistent Task Management**: Create, edit, and organize your tasks. All data is saved persistently and restored gracefully across app restarts.
- **Ambient Focus Music**: Enhance your concentration with high-quality, perfectly looped ambient soundscapes, including native support for:
  - Monsoon Breath
  - Morning at the Ghat
  - The Breathing Tide
- **Intelligent App Blocker (Android Only)**: Leverage native Android Accessibility Services to forcefully block distracting applications (like social media or games) during active focus sessions.
- **Multi-Platform Support**: Enjoy a seamless timer experience on both Mobile (Android/iOS) and Desktop (Linux/macOS/Windows) with platform-aware background process handling.

## Architecture

- Written in Dart using the **Flutter** framework.
- Uses **SharedPreferences** for lightning-fast local state persistence.
- Powered by **Flutter Background Service** for reliable mobile timer tracking.
- Features native **Android MethodChannels** for robust Accessibility Service integration.

## Getting Started

1. Clone the repository.
2. Ensure you have the Flutter SDK installed.
3. Run `flutter pub get` to fetch all dependencies.
4. Run `flutter run` on your target device or emulator.

*Note: For the App Blocker features on Android, you will be prompted to grant Accessibility permissions upon starting your first focus session.*
