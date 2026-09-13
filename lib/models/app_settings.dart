import 'package:flutter/material.dart';

/// Immutable model representing user preferences and application configuration.
///
/// Serves as the foundational domain model for the Settings feature.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.soundEffectsEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.dailyRemindersEnabled = false,
  });

  /// The active theme mode (defaults to [ThemeMode.dark] for the RPG visual theme).
  final ThemeMode themeMode;

  /// Whether sound effects (e.g. quest complete, level up) are enabled.
  final bool soundEffectsEnabled;

  /// Whether haptic vibrations on quest interaction are enabled.
  final bool hapticFeedbackEnabled;

  /// Whether daily quest notification reminders are scheduled.
  final bool dailyRemindersEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
    bool? dailyRemindersEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      dailyRemindersEnabled:
          dailyRemindersEnabled ?? this.dailyRemindersEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          themeMode == other.themeMode &&
          soundEffectsEnabled == other.soundEffectsEnabled &&
          hapticFeedbackEnabled == other.hapticFeedbackEnabled &&
          dailyRemindersEnabled == other.dailyRemindersEnabled;

  @override
  int get hashCode => Object.hash(
        themeMode,
        soundEffectsEnabled,
        hapticFeedbackEnabled,
        dailyRemindersEnabled,
      );

  @override
  String toString() =>
      'AppSettings(themeMode: $themeMode, sound: $soundEffectsEnabled, haptics: $hapticFeedbackEnabled, reminders: $dailyRemindersEnabled)';
}
