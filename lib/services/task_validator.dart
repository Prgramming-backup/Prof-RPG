class TaskValidationResult {
  const TaskValidationResult({
    this.titleError,
    this.xpError,
  });

  final String? titleError;
  final String? xpError;

  bool get isValid => titleError == null && xpError == null;
}

class TaskValidator {
  const TaskValidator();

  TaskValidationResult validate({
    required String title,
    required String xpText,
  }) {
    return TaskValidationResult(
      titleError: titleError(title),
      xpError: xpError(xpText),
    );
  }

  String? titleError(String title) {
    if (title.trim().isEmpty) {
      return 'Enter a task title.';
    }
    return null;
  }

  String? xpError(String xpText) {
    final parsed = int.tryParse(xpText.trim());
    if (parsed == null) {
      return 'Enter a whole number for the XP reward.';
    }
    if (parsed <= 0) {
      return 'XP reward must be greater than 0.';
    }
    return null;
  }

  int parseXp(String xpText) {
    final parsed = int.tryParse(xpText.trim());
    if (parsed == null || parsed <= 0) {
      throw FormatException('Invalid XP reward: $xpText');
    }
    return parsed;
  }

  String? normalizeDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
