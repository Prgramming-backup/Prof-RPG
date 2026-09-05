import 'package:flutter/material.dart';

import '../widgets/placeholder_panel.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: PlaceholderPanel(
        icon: Icons.insights_outlined,
        title: 'Campaign log',
        message:
            'Streaks, completed quests, and progress charts will appear here later.',
      ),
    );
  }
}
