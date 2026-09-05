import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'theme/app_theme.dart';

class ProRpgApp extends StatelessWidget {
  const ProRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
