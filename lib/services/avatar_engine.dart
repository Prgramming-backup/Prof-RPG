import 'package:flutter/material.dart';

import '../models/avatar_progression.dart';
import '../models/avatar_tier.dart';

/// Pure, deterministic engine responsible for mapping player levels to
/// avatar evolution tiers and calculating intra-tier progression.
///
/// Holds all tier thresholds and title definitions in a centralized, easily
/// modifiable registry.
class AvatarEngine {
  const AvatarEngine();

  /// Centralized source of truth for all avatar tiers, their level boundaries,
  /// display titles, and visual characteristics.
  static const List<AvatarTierDefinition> tiers = [
    AvatarTierDefinition(
      tier: AvatarTier.yoyaimo,
      title: 'Yoyaimo',
      minLevel: 1,
      maxLevel: 4,
      icon: Icons.spa_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFF4A5568), Color(0xFF2D3748)],
      borderWidth: 2.0,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.karen,
      title: 'Karen',
      minLevel: 5,
      maxLevel: 9,
      icon: Icons.campaign_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFFE53E3E), Color(0xFF9B2C2C)],
      borderWidth: 2.0,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.npc,
      title: 'NPC',
      minLevel: 10,
      maxLevel: 14,
      icon: Icons.smart_toy_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFF718096), Color(0xFF4A5568)],
      borderWidth: 2.0,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.broIsTrying,
      title: 'Bro Is Trying',
      minLevel: 15,
      maxLevel: 19,
      icon: Icons.directions_run,
      badgeSymbol: '',
      gradientColors: [Color(0xFFDD6B20), Color(0xFFC05621)],
      borderWidth: 2.5,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.lockIn,
      title: 'Lock In',
      minLevel: 20,
      maxLevel: 24,
      icon: Icons.center_focus_strong,
      badgeSymbol: '',
      gradientColors: [Color(0xFF3182CE), Color(0xFF2B6CB0)],
      borderWidth: 2.5,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.grinder,
      title: 'Grinder',
      minLevel: 25,
      maxLevel: 29,
      icon: Icons.hardware,
      badgeSymbol: '',
      gradientColors: [Color(0xFF805AD5), Color(0xFF6B46C1)],
      borderWidth: 2.5,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.based,
      title: 'Based',
      minLevel: 30,
      maxLevel: 34,
      icon: Icons.verified_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFF38A169), Color(0xFF2F855A)],
      borderWidth: 2.5,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.chadApprentice,
      title: 'Chad Apprentice',
      minLevel: 35,
      maxLevel: 39,
      icon: Icons.military_tech_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
      borderWidth: 2.5,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.chad,
      title: 'Chad',
      minLevel: 40,
      maxLevel: 49,
      icon: Icons.shield,
      badgeSymbol: '',
      gradientColors: [Color(0xFFD69E2E), Color(0xFFB7791F)],
      borderWidth: 3.0,
      hasGlow: false,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.sigma,
      title: 'Sigma',
      minLevel: 50,
      maxLevel: 59,
      icon: Icons.visibility,
      badgeSymbol: '',
      gradientColors: [Color(0xFF2B6CB0), Color(0xFF1A365D)],
      borderWidth: 3.0,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.sigmaGrindset,
      title: 'Sigma Grindset',
      minLevel: 60,
      maxLevel: 69,
      icon: Icons.speed,
      badgeSymbol: '',
      gradientColors: [Color(0xFF4C51BF), Color(0xFF2D3748)],
      borderWidth: 3.0,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.alpha,
      title: 'Alpha',
      minLevel: 70,
      maxLevel: 79,
      icon: Icons.workspace_premium,
      badgeSymbol: '',
      gradientColors: [Color(0xFFC53030), Color(0xFF742A2A)],
      borderWidth: 3.5,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.gigaChad,
      title: 'GigaChad',
      minLevel: 80,
      maxLevel: 99,
      icon: Icons.diamond_outlined,
      badgeSymbol: '',
      gradientColors: [Color(0xFFD69E2E), Color(0xFF744210)],
      borderWidth: 3.5,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.ultraChad,
      title: 'UltraChad',
      minLevel: 100,
      maxLevel: 149,
      icon: Icons.flare,
      badgeSymbol: '',
      gradientColors: [Color(0xFFE53E3E), Color(0xFFD69E2E)],
      borderWidth: 4.0,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.him,
      title: 'HIM',
      minLevel: 150,
      maxLevel: 199,
      icon: Icons.local_fire_department,
      badgeSymbol: '',
      gradientColors: [Color(0xFFFF5722), Color(0xFFBF360C)],
      borderWidth: 4.0,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.builtDifferent,
      title: 'Built Different',
      minLevel: 200,
      maxLevel: 299,
      icon: Icons.auto_awesome,
      badgeSymbol: '',
      gradientColors: [Color(0xFF9F7AEA), Color(0xFF319795)],
      borderWidth: 4.5,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.finalBoss,
      title: 'Final Boss',
      minLevel: 300,
      maxLevel: 499,
      icon: Icons.castle,
      badgeSymbol: '',
      gradientColors: [Color(0xFF553C9A), Color(0xFF1A202C)],
      borderWidth: 4.5,
      hasGlow: true,
    ),
    AvatarTierDefinition(
      tier: AvatarTier.productivityDemon,
      title: 'Productivity Demon',
      minLevel: 500,
      maxLevel: null,
      icon: Icons.crisis_alert,
      badgeSymbol: '',
      gradientColors: [Color(0xFFFF0055), Color(0xFF7928CA)],
      borderWidth: 5.0,
      hasGlow: true,
    ),
  ];

  /// Resolves the tier definition corresponding to [tier].
  AvatarTierDefinition definitionForTier(AvatarTier tier) {
    return tiers.firstWhere((def) => def.tier == tier);
  }

  /// Computes the complete [AvatarProgression] for a player's [level].
  ///
  /// - Negative or zero levels are defensively clamped to `1`.
  /// - Progress within the current tier is computed strictly as:
  ///   `(level - minLevel) / (maxLevel - minLevel)` clamped to `[0.0, 1.0]`.
  /// - The final tier has no next tier and its progress is safely `1.0`.
  AvatarProgression progressionFor(int level) {
    final safeLevel = level < 1 ? 1 : level;

    // Find the matching tier index
    var matchIndex = 0;
    for (var i = 0; i < tiers.length; i++) {
      if (tiers[i].containsLevel(safeLevel)) {
        matchIndex = i;
        break;
      }
    }

    final currentDef = tiers[matchIndex];
    final hasNext = matchIndex < tiers.length - 1;
    final nextDef = hasNext ? tiers[matchIndex + 1] : null;

    final double progress;
    if (currentDef.maxLevel == null) {
      // Final infinite tier (e.g. 500+)
      progress = 1.0;
    } else if (currentDef.maxLevel == currentDef.minLevel) {
      progress = 1.0;
    } else {
      final span = currentDef.maxLevel! - currentDef.minLevel;
      final rawProgress = (safeLevel - currentDef.minLevel) / span;
      progress = rawProgress.clamp(0.0, 1.0);
    }

    return AvatarProgression(
      tier: currentDef.tier,
      title: currentDef.title,
      level: safeLevel,
      minLevel: currentDef.minLevel,
      maxLevel: currentDef.maxLevel,
      progress: progress,
      nextTier: nextDef?.tier,
      nextTitle: nextDef?.title,
      definition: currentDef,
    );
  }
}
