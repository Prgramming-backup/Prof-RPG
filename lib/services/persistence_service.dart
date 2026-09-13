/// Foundational key-value persistence contract for the application.
///
/// Provides an asynchronous storage abstraction to decouple state/repositories
/// from the underlying persistence mechanism (e.g. In-Memory, SharedPreferences,
/// or SQLite/Drift).
abstract class PersistenceService {
  /// Reads a string value for [key], or `null` if not found.
  Future<String?> getString(String key);

  /// Stores a string [value] for [key].
  Future<void> setString(String key, String value);

  /// Reads an integer value for [key], or `null` if not found.
  Future<int?> getInt(String key);

  /// Stores an integer [value] for [key].
  Future<void> setInt(String key, int value);

  /// Reads a boolean value for [key], or `null` if not found.
  Future<bool?> getBool(String key);

  /// Stores a boolean [value] for [key].
  Future<void> setBool(String key, bool value);

  /// Removes the entry for [key].
  Future<void> remove(String key);

  /// Clears all stored entries.
  Future<void> clear();
}

/// In-memory implementation of [PersistenceService] for testing and early development.
class InMemoryPersistenceService implements PersistenceService {
  final Map<String, Object> _store = {};

  @override
  Future<String?> getString(String key) async {
    final value = _store[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _store[key];
    return value is int ? value : null;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _store[key];
    return value is bool ? value : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
