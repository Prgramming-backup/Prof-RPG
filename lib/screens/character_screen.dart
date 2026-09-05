import 'package:flutter/material.dart';

import '../widgets/placeholder_panel.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Character')),
      body: PlaceholderPanel(
        icon: Icons.shield_outlined,
        title: 'Hero sheet',
        message:
            'Levels, XP, and character progression will live here. Nothing is implemented yet.',
      ),
    );
  }
}
