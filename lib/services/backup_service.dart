import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/task.dart';
import '../models/xp_transaction.dart';

/// Structured container holding validated, deserialized backup contents.
class BackupData {
  const BackupData({
    required this.formatVersion,
    required this.app,
    required this.exportedAt,
    required this.tasks,
    required this.xpTransactions,
  });

  final int formatVersion;
  final String app;
  final DateTime exportedAt;
  final List<Task> tasks;
  final List<XpTransaction> xpTransactions;
}

/// Result of a backup validation check.
class BackupValidationResult {
  const BackupValidationResult.valid(this.data)
      : isValid = true,
        errorMessage = null;

  const BackupValidationResult.invalid(this.errorMessage)
      : isValid = false,
        data = null;

  final bool isValid;
  final String? errorMessage;
  final BackupData? data;
}

/// Result of an export-to-file operation.
class BackupExportResult {
  const BackupExportResult.success({required this.filePath})
      : isSuccess = true,
        isCancelled = false,
        errorMessage = null;

  const BackupExportResult.cancelled()
      : isSuccess = false,
        isCancelled = true,
        filePath = null,
        errorMessage = null;

  const BackupExportResult.failure(this.errorMessage)
      : isSuccess = false,
        isCancelled = false,
        filePath = null;

  final bool isSuccess;
  final bool isCancelled;
  final String? filePath;
  final String? errorMessage;
}

/// Result of an import-from-file operation.
class BackupImportResult {
  const BackupImportResult.success(this.data, {this.fileName})
      : isSuccess = true,
        isCancelled = false,
        errorMessage = null;

  const BackupImportResult.cancelled()
      : isSuccess = false,
        isCancelled = true,
        data = null,
        fileName = null,
        errorMessage = null;

  const BackupImportResult.failure(this.errorMessage)
      : isSuccess = false,
        isCancelled = false,
        data = null,
        fileName = null;

  final bool isSuccess;
  final bool isCancelled;
  final BackupData? data;
  final String? fileName;
  final String? errorMessage;
}

/// Pure and dedicated backup service handling export, import, serialization,
/// and schema validation for Pro-RPG user progress.
class BackupService {
  const BackupService({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// Current backup schema version.
  static const int currentFormatVersion = 1;

  /// Application identifier embedded in backup files.
  static const String appIdentifier = 'Pro-RPG';

  /// Default file name suggested during export.
  static const String defaultFileName = 'pro-rpg-backup.json';

  final DateTime Function() _clock;

  /// Serializes tasks and XP transactions into human-readable, portable JSON.
  String serializeBackup({
    required List<Task> tasks,
    required List<XpTransaction> xpTransactions,
    DateTime? exportedAt,
  }) {
    final map = <String, dynamic>{
      'formatVersion': currentFormatVersion,
      'app': appIdentifier,
      'exportedAt': (exportedAt ?? _clock()).toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'xpTransactions': xpTransactions.map((tx) => tx.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Thoroughly validates a raw backup JSON string.
  ///
  /// Rejects malformed JSON, unsupported format versions, and corrupted or
  /// incomplete records without mutating any application state.
  BackupValidationResult validateBackup(String jsonContent) {
    if (jsonContent.trim().isEmpty) {
      return const BackupValidationResult.invalid(
        'The backup file is empty.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } catch (_) {
      return const BackupValidationResult.invalid(
        'The backup file is corrupted or not valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const BackupValidationResult.invalid(
        'Invalid backup structure: root must be a JSON object.',
      );
    }

    // 1. Verify app identifier
    final app = decoded['app'];
    if (app == null || app != appIdentifier) {
      return const BackupValidationResult.invalid(
        'Incompatible backup file: not a recognized Pro-RPG backup.',
      );
    }

    // 2. Verify format version
    final version = decoded['formatVersion'];
    if (version == null) {
      return const BackupValidationResult.invalid(
        'Invalid backup: missing format version.',
      );
    }
    if (version is! int || version != currentFormatVersion) {
      return BackupValidationResult.invalid(
        'Unsupported backup version ($version). This application requires version $currentFormatVersion.',
      );
    }

    // 3. Verify export timestamp
    final rawExportedAt = decoded['exportedAt'];
    DateTime exportedAt;
    if (rawExportedAt is String) {
      try {
        exportedAt = DateTime.parse(rawExportedAt);
      } catch (_) {
        return const BackupValidationResult.invalid(
          'Invalid backup: invalid exportedAt date format.',
        );
      }
    } else {
      exportedAt = _clock();
    }

    // 4. Validate tasks list
    final rawTasks = decoded['tasks'];
    if (rawTasks == null || rawTasks is! List) {
      return const BackupValidationResult.invalid(
        'Invalid backup: "tasks" array is missing or invalid.',
      );
    }

    final parsedTasks = <Task>[];
    for (var i = 0; i < rawTasks.length; i++) {
      final item = rawTasks[i];
      if (item is! Map<String, dynamic>) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: expected JSON object.',
        );
      }

      final id = item['id'];
      if (id is! String || id.trim().isEmpty) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: missing or invalid "id".',
        );
      }

      final title = item['title'];
      if (title is! String || title.trim().isEmpty) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: missing or invalid "title".',
        );
      }

      final xpReward = item['xpReward'];
      if (xpReward is! num || xpReward <= 0) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: "xpReward" must be greater than 0.',
        );
      }

      final rawCreatedAt = item['createdAt'];
      if (rawCreatedAt is! String) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: missing "createdAt".',
        );
      }
      try {
        DateTime.parse(rawCreatedAt);
      } catch (_) {
        return BackupValidationResult.invalid(
          'Invalid task record at index $i: invalid "createdAt" format.',
        );
      }

      try {
        parsedTasks.add(Task.fromJson(item));
      } catch (e) {
        return BackupValidationResult.invalid(
          'Malformed task record at index $i: $e',
        );
      }
    }

    // 5. Validate XP transactions list
    final rawTransactions = decoded['xpTransactions'];
    if (rawTransactions == null || rawTransactions is! List) {
      return const BackupValidationResult.invalid(
        'Invalid backup: "xpTransactions" array is missing or invalid.',
      );
    }

    final parsedTransactions = <XpTransaction>[];
    for (var i = 0; i < rawTransactions.length; i++) {
      final item = rawTransactions[i];
      if (item is! Map<String, dynamic>) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: expected JSON object.',
        );
      }

      final id = item['id'];
      if (id is! String || id.trim().isEmpty) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing or invalid "id".',
        );
      }

      final sourceTaskId = item['sourceTaskId'];
      if (sourceTaskId is! String || sourceTaskId.trim().isEmpty) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing or invalid "sourceTaskId".',
        );
      }

      final completionId = item['completionId'];
      if (completionId is! String || completionId.trim().isEmpty) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing or invalid "completionId".',
        );
      }

      final baseXp = item['baseXp'];
      if (baseXp is! num) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing or invalid "baseXp".',
        );
      }

      final awardedXp = item['awardedXp'];
      if (awardedXp is! num) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing or invalid "awardedXp".',
        );
      }

      final rawTimestamp = item['timestamp'];
      if (rawTimestamp is! String) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: missing "timestamp".',
        );
      }
      try {
        DateTime.parse(rawTimestamp);
      } catch (_) {
        return BackupValidationResult.invalid(
          'Invalid XP transaction at index $i: invalid "timestamp" format.',
        );
      }

      try {
        parsedTransactions.add(XpTransaction.fromJson(item));
      } catch (e) {
        return BackupValidationResult.invalid(
          'Malformed XP transaction at index $i: $e',
        );
      }
    }

    return BackupValidationResult.valid(
      BackupData(
        formatVersion: version,
        app: app,
        exportedAt: exportedAt,
        tasks: parsedTasks,
        xpTransactions: parsedTransactions,
      ),
    );
  }

  /// Deserializes a validated JSON backup string into [BackupData].
  ///
  /// Throws [FormatException] if validation fails.
  BackupData deserializeBackup(String jsonContent) {
    final result = validateBackup(jsonContent);
    if (!result.isValid) {
      throw FormatException(result.errorMessage ?? 'Invalid backup.');
    }
    return result.data!;
  }

  /// Opens the system save file dialog and writes the backup JSON to disk.
  ///
  /// Uses [FilePicker.saveFile] (file_picker v12+) which takes [Uint8List] bytes
  /// and returns the saved file [Uri], or `null` if the user cancelled.
  Future<BackupExportResult> exportToFile({
    required List<Task> tasks,
    required List<XpTransaction> xpTransactions,
    String? explicitPath,
  }) async {
    try {
      final jsonContent = serializeBackup(
        tasks: tasks,
        xpTransactions: xpTransactions,
      );
      final bytes = Uint8List.fromList(utf8.encode(jsonContent));

      if (explicitPath != null) {
        // Bypass the picker and write directly (used for testing / explicit paths).
        final file = File(explicitPath);
        await file.writeAsBytes(bytes);
        return BackupExportResult.success(filePath: explicitPath);
      }

      final uri = await FilePicker.saveFile(
        dialogTitle: 'Save Pro-RPG Backup',
        fileName: defaultFileName,
        bytes: bytes,
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (uri == null) {
        return const BackupExportResult.cancelled();
      }

      // On desktop platforms, uri.toFilePath() gives the actual path.
      final savedPath = uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
      return BackupExportResult.success(filePath: savedPath);
    } catch (e) {
      return BackupExportResult.failure('Failed to export backup: $e');
    }
  }

  /// Opens the system file picker, reads the chosen file, and validates its contents.
  ///
  /// Uses [FilePicker.pickFile] (file_picker v12+) which returns a [PlatformFile?].
  /// On platforms where [PlatformFile.path] is null (e.g. Web), falls back to
  /// reading file bytes directly via [PlatformFile.readAsBytes].
  Future<BackupImportResult> importFromFile({
    String? explicitPath,
  }) async {
    try {
      String? fileName;

      if (explicitPath == null) {
        final platformFile = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (platformFile == null) {
          return const BackupImportResult.cancelled();
        }

        fileName = platformFile.name;
        final path = platformFile.path;

        if (path == null) {
          // Web or platforms where a file path isn't available — use bytes.
          final rawBytes = await platformFile.readAsBytes();
          final content = utf8.decode(rawBytes);
          final validation = validateBackup(content);
          if (!validation.isValid) {
            return BackupImportResult.failure(validation.errorMessage);
          }
          return BackupImportResult.success(
            validation.data!,
            fileName: fileName,
          );
        }

        final file = File(path);
        if (!await file.exists()) {
          return const BackupImportResult.failure(
            'The selected backup file does not exist.',
          );
        }

        final content = await file.readAsString();
        final validation = validateBackup(content);
        if (!validation.isValid) {
          return BackupImportResult.failure(validation.errorMessage);
        }

        return BackupImportResult.success(
          validation.data!,
          fileName: fileName,
        );
      }

      // explicitPath provided — used for testing / programmatic invocations.
      final file = File(explicitPath);
      if (!await file.exists()) {
        return const BackupImportResult.failure(
          'The selected backup file does not exist.',
        );
      }

      final content = await file.readAsString();
      final validation = validateBackup(content);
      if (!validation.isValid) {
        return BackupImportResult.failure(validation.errorMessage);
      }

      return BackupImportResult.success(
        validation.data!,
        fileName: file.uri.pathSegments.last,
      );
    } catch (e) {
      return BackupImportResult.failure('Failed to read backup file: $e');
    }
  }
}


