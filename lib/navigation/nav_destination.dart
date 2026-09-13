import 'package:flutter/material.dart';

/// Available primary navigation destinations in the application shell.
enum AppTab {
  home,
  character,
  stats,
  settings,
}

/// Metadata descriptor for a bottom navigation bar destination.
class NavDestination {
  const NavDestination({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.tooltip,
  });

  /// The enum identifier for this tab.
  final AppTab tab;

  /// Label shown beneath or beside the icon.
  final String label;

  /// Unselected icon representation.
  final IconData icon;

  /// Selected icon representation.
  final IconData selectedIcon;

  /// Optional tooltip override for accessibility.
  final String? tooltip;

  /// Complete list of primary app destinations ordered by navigation tab index.
  static const List<NavDestination> items = [
    NavDestination(
      tab: AppTab.home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      tooltip: 'Adventure board',
    ),
    NavDestination(
      tab: AppTab.character,
      label: 'Character',
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield,
      tooltip: 'Hero profile',
    ),
    NavDestination(
      tab: AppTab.stats,
      label: 'Stats',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      tooltip: 'Campaign statistics',
    ),
    NavDestination(
      tab: AppTab.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      tooltip: 'Guild options',
    ),
  ];
}
