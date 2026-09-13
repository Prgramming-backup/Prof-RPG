import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import '../state/task_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.backupService = const BackupService(),
  });

  final BackupService backupService;

  Future<void> _exportBackup(BuildContext context) async {
    final controller = TaskScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final result = await backupService.exportToFile(
      tasks: controller.tasks,
      xpTransactions: controller.xpTransactions,
    );

    if (!context.mounted) return;

    if (result.isSuccess) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.filePath != null
                ? 'Backup exported to: ${result.filePath}'
                : 'Backup exported successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!result.isCancelled) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to export backup.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restore from backup?'),
          content: const Text(
            'Restoring a backup will replace your current quests, XP history, and streak. '
            'This cannot be undone. Make sure you have exported your current progress first.',
          ),
          actions: [
            TextButton(
              key: const Key('cancel-restore-button'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm-restore-button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final controller = TaskScope.of(context);

    final result = await backupService.importFromFile();

    if (!context.mounted) return;

    if (result.isSuccess && result.data != null) {
      await controller.restoreProgress(
        tasks: result.data!.tasks,
        xpTransactions: result.data!.xpTransactions,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Restored ${result.data!.tasks.length} quests and '
            '${result.data!.xpTransactions.length} XP transactions successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!result.isCancelled) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Failed to restore backup. Your existing data was preserved.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.save_outlined, color: colors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Local Backup & Restore',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Export your quests, XP history, and streak to a portable offline file '
                      'or import a backup created on another device.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('export-backup-button'),
                            onPressed: () => _exportBackup(context),
                            icon: const Icon(Icons.file_upload_outlined, size: 18),
                            label: const Text('Export'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('import-backup-button'),
                            onPressed: () => _importBackup(context),
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('Import'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: colors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Data Storage',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All progress is automatically saved to your local device storage. '
                      'No internet connection or account required.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
