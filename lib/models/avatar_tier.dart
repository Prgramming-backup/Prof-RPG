import 'package:flutter/material.dart';

/// Supported avatar progression tiers.
enum AvatarTier {
  yoyaimo,
  karen,
  npc,
  broIsTrying,
  lockIn,
  grinder,
  based,
  chadApprentice,
  chad,
  sigma,
  sigmaGrindset,
  alpha,
  gigaChad,
  ultraChad,
  him,
  builtDifferent,
  finalBoss,
  productivityDemon,
}

/// Metadata definition for an [AvatarTier], holding all tier thresholds,
/// display titles, and visual characteristics.
class AvatarTierDefinition {
  const AvatarTierDefinition({
    required this.tier,
    required this.title,
    required this.minLevel,
    this.maxLevel,
    required this.icon,
    required this.badgeSymbol,
    required this.gradientColors,
    this.borderColor,
    this.borderWidth = 2.5,
    this.hasGlow = false,
  });

  /// The enum identifier for this tier.
  final AvatarTier tier;

  /// Fun display title (e.g. 'GigaChad', 'Productivity Demon').
  final String title;

  /// Minimum level required for this tier (inclusive).
  final int minLevel;

  /// Maximum level for this tier (inclusive), or `null` if unbounded (final tier).
  final int? maxLevel;

  /// Primary icon representing this avatar tier visually.
  final IconData icon;

  /// Short badge symbol/emoji representing this tier.
  final String badgeSymbol;

  /// Gradient colors for the avatar's circular backdrop.
  final List<Color> gradientColors;

  /// Custom border color override (or falls back to theme primary/accent).
  final Color? borderColor;

  /// Border stroke width for the avatar circle.
  final double borderWidth;

  /// Whether this tier displays an outer radiant glow aura.
  final bool hasGlow;

  /// Returns whether a given [level] falls within this tier's bounds.
  bool containsLevel(int level) {
    if (level < minLevel) return false;
    if (maxLevel != null && level > maxLevel!) return false;
    return true;
  }
}
