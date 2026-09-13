import 'avatar_tier.dart';

/// An immutable snapshot of a player's avatar progression state for a given level.
///
/// Contains all calculated fields needed by UI widgets to render avatar visuals,
/// progression bars, and evolution hints without performing any business logic.
class AvatarProgression {
  const AvatarProgression({
    required this.tier,
    required this.title,
    required this.level,
    required this.minLevel,
    this.maxLevel,
    required this.progress,
    this.nextTier,
    this.nextTitle,
    required this.definition,
    this.currentTierXp,
    this.tierTotalXp,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'progress must be between 0.0 and 1.0');

  /// The player's current avatar tier identifier.
  final AvatarTier tier;

  /// The fun display title for this tier (e.g. 'Sigma', 'GigaChad').
  final String title;

  /// The player's current level. Always `>= 1`.
  final int level;

  /// The minimum level of the current tier.
  final int minLevel;

  /// The maximum level of the current tier, or `null` for the final tier.
  final int? maxLevel;

  /// Progress toward the next avatar tier as a fraction in the range `[0.0, 1.0]`.
  final double progress;

  /// The upcoming avatar tier, or `null` if this is the final tier.
  final AvatarTier? nextTier;

  /// The display title of the upcoming avatar tier, or `null` if none.
  final String? nextTitle;

  /// Visual and thematic metadata for the current tier.
  final AvatarTierDefinition definition;

  /// XP earned within the current tier's level range, or `null` if unbounded.
  final int? currentTierXp;

  /// Total XP required to complete the current tier's level range, or `null` if final tier.
  final int? tierTotalXp;

  /// Whether there is another evolution stage beyond the current tier.
  bool get hasNextEvolution => nextTier != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarProgression &&
          tier == other.tier &&
          title == other.title &&
          level == other.level &&
          minLevel == other.minLevel &&
          maxLevel == other.maxLevel &&
          progress == other.progress &&
          nextTier == other.nextTier &&
          nextTitle == other.nextTitle;

  @override
  int get hashCode => Object.hash(
        tier,
        title,
        level,
        minLevel,
        maxLevel,
        progress,
        nextTier,
        nextTitle,
      );

  @override
  String toString() =>
      'AvatarProgression('
      'tier: $tier, '
      'title: "$title", '
      'level: $level, '
      'minLevel: $minLevel, '
      'maxLevel: $maxLevel, '
      'progress: ${(progress * 100).toStringAsFixed(1)}%, '
      'nextTier: $nextTier, '
      'nextTitle: "$nextTitle")';
}
