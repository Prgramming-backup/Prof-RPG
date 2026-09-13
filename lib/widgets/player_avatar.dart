import 'package:flutter/material.dart';

import '../models/avatar_progression.dart';
import '../services/avatar_engine.dart';

/// Reusable avatar component for the player character that visually reflects
/// the player's current avatar evolution tier.
///
/// Designed with pure Flutter UI widgets — no external assets, images, or packages.
/// As the player's level advances through tiers (from Yoyaimo to Productivity Demon),
/// the avatar dynamically evolves its color gradient, border styling, primary icon,
/// radiant aura, and badge ornaments.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    this.size = 96,
    this.level = 1,
    this.progression,
    this.showLevelBadge = true,
    this.showTierSymbol = true,
  });

  /// The diameter of the avatar circle.
  final double size;

  /// The player's current level. Used to derive [AvatarProgression] if not provided directly.
  final int level;

  /// Optional pre-computed [AvatarProgression]. If omitted, derived from [level].
  final AvatarProgression? progression;

  /// Whether to render the 'Lv X' badge at the bottom-right.
  final bool showLevelBadge;

  /// Whether to render the tier badge symbol at the top-right.
  final bool showTierSymbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentProgression =
        progression ?? const AvatarEngine().progressionFor(level);
    final def = currentProgression.definition;

    final baseBorderColor =
        def.borderColor ?? def.gradientColors.first.withValues(alpha: 0.85);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // --- Outer aura glow for high tiers (Sigma+) ---
          if (def.hasGlow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: def.gradientColors.first.withValues(alpha: 0.45),
                    blurRadius: size * 0.22,
                    spreadRadius: size * 0.04,
                  ),
                ],
              ),
            ),

          // --- Outer ornament ring for ultra tiers (GigaChad+) ---
          if (def.borderWidth >= 3.5)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: def.gradientColors.last.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
            ),

          // --- Main avatar circle ---
          Container(
            width: def.borderWidth >= 3.5 ? size - 6 : size,
            height: def.borderWidth >= 3.5 ? size - 6 : size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: def.gradientColors,
              ),
              border: Border.all(
                color: baseBorderColor,
                width: def.borderWidth,
              ),
            ),
            child: Center(
              child: Icon(
                def.icon,
                size: size * 0.44,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),

          // --- Top-right tier symbol/emoji badge ---
          if (showTierSymbol && def.badgeSymbol.isNotEmpty)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: EdgeInsets.all(size * 0.04),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseBorderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  def.badgeSymbol,
                  style: TextStyle(
                    fontSize: size * 0.16,
                    height: 1.1,
                  ),
                ),
              ),
            ),

          // --- Bottom-right level badge ---
          if (showLevelBadge)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'Lv ${currentProgression.level}',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: size * 0.13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
