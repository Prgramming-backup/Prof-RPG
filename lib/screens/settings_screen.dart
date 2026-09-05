import 'package:flutter/material.dart';

import '../widgets/placeholder_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: PlaceholderPanel(
        icon: Icons.settings_outlined,
        title: 'Guild options',
        message:
            'Preferences and local data options will be added when persistence is in place.',
      ),
    );
  }
}
