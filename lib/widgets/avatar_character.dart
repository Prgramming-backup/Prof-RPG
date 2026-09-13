import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/avatar_tier.dart';

/// Cartoon RPG character portrait driven purely by [AvatarTier].
///
/// No level math lives here — callers pass the already-resolved tier.
class AvatarCharacterPortrait extends StatelessWidget {
  const AvatarCharacterPortrait({
    super.key,
    required this.tier,
    required this.size,
    this.accentColors = const [Color(0xFF4A5568), Color(0xFF2D3748)],
  });

  final AvatarTier tier;
  final double size;
  final List<Color> accentColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AvatarCharacterPainter(
          tier: tier,
          accentColors: accentColors,
        ),
      ),
    );
  }
}

class _AvatarCharacterPainter extends CustomPainter {
  _AvatarCharacterPainter({
    required this.tier,
    required this.accentColors,
  });

  final AvatarTier tier;
  final List<Color> accentColors;

  int get _stage => AvatarTier.values.indexOf(tier);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    _paintAura(canvas, c, s);
    _paintBody(canvas, c, s);
    _paintHead(canvas, c, s);
    _paintGear(canvas, c, s);
  }

  void _paintAura(Canvas canvas, Offset c, double s) {
    if (_stage < 9) return;

    final intensity = ((_stage - 8) / 9).clamp(0.15, 1.0);
    final paint = Paint()
      ..color = accentColors.first.withValues(alpha: 0.18 + intensity * 0.28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.08);

    canvas.drawCircle(c, s * (0.42 + intensity * 0.08), paint);

    if (_stage >= 14) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..color = accentColors.last.withValues(alpha: 0.55);
      canvas.drawCircle(c, s * 0.46, ring);
    }

    if (_stage >= 16) {
      final spark = Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.7);
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3;
        final p = Offset(
          c.dx + math.cos(a) * s * 0.44,
          c.dy + math.sin(a) * s * 0.44,
        );
        canvas.drawCircle(p, s * 0.025, spark);
      }
    }
  }

  void _paintBody(Canvas canvas, Offset c, double s) {
    final torsoTop = c.dy + s * 0.02;
    final torsoBottom = c.dy + s * 0.38;
    final shoulderW = s * (0.22 + (_stage >= 8 ? 0.04 : 0) + (_stage >= 12 ? 0.03 : 0));

    final shirt = Paint()..color = _shirtColor();

    final torso = Path()
      ..moveTo(c.dx - shoulderW, torsoTop)
      ..quadraticBezierTo(
        c.dx - shoulderW * 1.05,
        (torsoTop + torsoBottom) / 2,
        c.dx - shoulderW * 0.75,
        torsoBottom,
      )
      ..lineTo(c.dx + shoulderW * 0.75, torsoBottom)
      ..quadraticBezierTo(
        c.dx + shoulderW * 1.05,
        (torsoTop + torsoBottom) / 2,
        c.dx + shoulderW,
        torsoTop,
      )
      ..close();

    // Cape behind torso for high tiers
    if (_stage >= 11) {
      final cape = Paint()..color = const Color(0xFF9B1C1C).withValues(alpha: 0.85);
      final capePath = Path()
        ..moveTo(c.dx - shoulderW * 0.9, torsoTop)
        ..quadraticBezierTo(
          c.dx - s * 0.38,
          torsoBottom + s * 0.05,
          c.dx - s * 0.12,
          torsoBottom + s * 0.08,
        )
        ..lineTo(c.dx + s * 0.12, torsoBottom + s * 0.08)
        ..quadraticBezierTo(
          c.dx + s * 0.38,
          torsoBottom + s * 0.05,
          c.dx + shoulderW * 0.9,
          torsoTop,
        )
        ..close();
      canvas.drawPath(capePath, cape);
    }

    canvas.drawPath(torso, shirt);

    final armPaint = Paint()
      ..color = const Color(0xFFE8B896)
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final armRaise = _stage >= 3 ? -s * 0.02 : s * 0.01;
    final armSpread = _stage >= 8 ? s * 0.08 : s * 0.04;
    canvas.drawLine(
      Offset(c.dx - shoulderW * 0.85, torsoTop + s * 0.04),
      Offset(c.dx - shoulderW - armSpread, torsoTop + s * 0.18 + armRaise),
      armPaint,
    );
    canvas.drawLine(
      Offset(c.dx + shoulderW * 0.85, torsoTop + s * 0.04),
      Offset(c.dx + shoulderW + armSpread, torsoTop + s * 0.18 + armRaise),
      armPaint,
    );

    if (_stage >= 8) {
      final armor = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.55);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx, torsoTop + s * 0.12),
            width: shoulderW * 1.1,
            height: s * 0.12,
          ),
          Radius.circular(s * 0.02),
        ),
        armor,
      );
    }

    if (_stage >= 5) {
      canvas.drawRect(
        Rect.fromLTWH(
          c.dx - shoulderW * 0.7,
          torsoBottom - s * 0.06,
          shoulderW * 1.4,
          s * 0.035,
        ),
        Paint()..color = const Color(0xFF2D3748),
      );
      canvas.drawCircle(
        Offset(c.dx, torsoBottom - s * 0.042),
        s * 0.02,
        Paint()..color = const Color(0xFFECC94B),
      );
    }
  }

  void _paintHead(Canvas canvas, Offset c, double s) {
    final headCenter = Offset(c.dx, c.dy - s * 0.16);
    final headR = s * 0.175;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy - s * 0.02),
          width: s * 0.08,
          height: s * 0.08,
        ),
        Radius.circular(s * 0.02),
      ),
      Paint()..color = const Color(0xFFE8B896),
    );

    canvas.drawCircle(headCenter, headR, Paint()..color = const Color(0xFFF0C4A0));
    _paintHair(canvas, headCenter, headR);

    final eyeY = headCenter.dy - s * 0.01;
    final eyePaint = Paint()..color = const Color(0xFF1A202C);
    final eyeSpread = s * 0.055;
    final eyeSize = s * (_stage >= 9 ? 0.028 : 0.022);

    if (_stage >= 4) {
      final brow = Paint()
        ..color = const Color(0xFF2D3748)
        ..strokeWidth = s * 0.012
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(headCenter.dx - eyeSpread - s * 0.02, eyeY - s * 0.035),
        Offset(headCenter.dx - eyeSpread + s * 0.02, eyeY - s * 0.02),
        brow,
      );
      canvas.drawLine(
        Offset(headCenter.dx + eyeSpread + s * 0.02, eyeY - s * 0.035),
        Offset(headCenter.dx + eyeSpread - s * 0.02, eyeY - s * 0.02),
        brow,
      );
    }

    canvas.drawCircle(Offset(headCenter.dx - eyeSpread, eyeY), eyeSize, eyePaint);
    canvas.drawCircle(Offset(headCenter.dx + eyeSpread, eyeY), eyeSize, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF9B2C2C)
      ..strokeWidth = s * 0.012
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (_stage == 0) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(headCenter.dx, headCenter.dy + s * 0.05),
          width: s * 0.08,
          height: s * 0.05,
        ),
        0.2,
        math.pi - 0.4,
        false,
        mouthPaint,
      );
    } else if (_stage == 1) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headCenter.dx, headCenter.dy + s * 0.055),
          width: s * 0.05,
          height: s * 0.04,
        ),
        Paint()..color = const Color(0xFF742A2A),
      );
    } else if (_stage >= 12) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(headCenter.dx, headCenter.dy + s * 0.045),
          width: s * 0.12,
          height: s * 0.08,
        ),
        0.15,
        math.pi - 0.3,
        false,
        mouthPaint..strokeWidth = s * 0.016,
      );
    } else {
      canvas.drawLine(
        Offset(headCenter.dx - s * 0.03, headCenter.dy + s * 0.055),
        Offset(headCenter.dx + s * 0.03, headCenter.dy + s * 0.055),
        mouthPaint,
      );
    }

    if (_stage <= 3) {
      final blush = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.35);
      canvas.drawCircle(
        Offset(headCenter.dx - s * 0.1, headCenter.dy + s * 0.03),
        s * 0.025,
        blush,
      );
      canvas.drawCircle(
        Offset(headCenter.dx + s * 0.1, headCenter.dy + s * 0.03),
        s * 0.025,
        blush,
      );
    }
  }

  void _paintHair(Canvas canvas, Offset head, double headR) {
    final hair = Paint()..color = _hairColor();
    final path = Path()
      ..moveTo(head.dx - headR * 0.95, head.dy)
      ..quadraticBezierTo(
        head.dx - headR * 0.7,
        head.dy - headR * 1.35,
        head.dx,
        head.dy - headR * 1.15,
      )
      ..quadraticBezierTo(
        head.dx + headR * 0.7,
        head.dy - headR * 1.35,
        head.dx + headR * 0.95,
        head.dy,
      )
      ..quadraticBezierTo(head.dx, head.dy - headR * 0.35, head.dx - headR * 0.95, head.dy)
      ..close();
    canvas.drawPath(path, hair);

    if (_stage >= 9) {
      canvas.drawPath(
        Path()
          ..moveTo(head.dx - headR * 0.7, head.dy - headR * 0.2)
          ..quadraticBezierTo(
            head.dx - headR * 0.1,
            head.dy + headR * 0.15,
            head.dx + headR * 0.15,
            head.dy - headR * 0.05,
          ),
        Paint()
          ..color = _hairColor()
          ..style = PaintingStyle.stroke
          ..strokeWidth = headR * 0.22
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintGear(Canvas canvas, Offset c, double s) {
    final head = Offset(c.dx, c.dy - s * 0.16);

    switch (tier) {
      case AvatarTier.yoyaimo:
        final stem = Paint()
          ..color = const Color(0xFF48BB78)
          ..strokeWidth = s * 0.018
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(head.dx, head.dy - s * 0.18),
          Offset(head.dx, head.dy - s * 0.28),
          stem,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx - s * 0.04, head.dy - s * 0.27),
            width: s * 0.07,
            height: s * 0.04,
          ),
          Paint()..color = const Color(0xFF68D391),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx + s * 0.04, head.dy - s * 0.27),
            width: s * 0.07,
            height: s * 0.04,
          ),
          Paint()..color = const Color(0xFF68D391),
        );
      case AvatarTier.karen:
        final glass = Paint()..color = const Color(0xFF1A202C);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx - s * 0.055, head.dy - s * 0.01),
              width: s * 0.08,
              height: s * 0.045,
            ),
            Radius.circular(s * 0.01),
          ),
          glass,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx + s * 0.055, head.dy - s * 0.01),
              width: s * 0.08,
              height: s * 0.045,
            ),
            Radius.circular(s * 0.01),
          ),
          glass,
        );
        canvas.drawLine(
          Offset(head.dx - s * 0.015, head.dy - s * 0.01),
          Offset(head.dx + s * 0.015, head.dy - s * 0.01),
          Paint()
            ..color = const Color(0xFF1A202C)
            ..strokeWidth = s * 0.012,
        );
      case AvatarTier.npc:
        final q = TextPainter(
          text: TextSpan(
            text: '?',
            style: TextStyle(
              color: const Color(0xFFE2E8F0),
              fontSize: s * 0.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        q.paint(canvas, Offset(head.dx + s * 0.14, head.dy - s * 0.28));
      case AvatarTier.broIsTrying:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx, head.dy - s * 0.12),
              width: s * 0.28,
              height: s * 0.045,
            ),
            Radius.circular(s * 0.02),
          ),
          Paint()..color = const Color(0xFFED8936),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx + s * 0.14, head.dy),
            width: s * 0.03,
            height: s * 0.045,
          ),
          Paint()..color = const Color(0xFF63B3ED),
        );
      case AvatarTier.lockIn:
        final hp = Paint()
          ..color = const Color(0xFF2B6CB0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.03;
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.38, height: s * 0.34),
          math.pi * 1.15,
          math.pi * 0.7,
          false,
          hp,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx - s * 0.17, head.dy),
              width: s * 0.05,
              height: s * 0.1,
            ),
            Radius.circular(s * 0.015),
          ),
          Paint()..color = const Color(0xFF2B6CB0),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx + s * 0.17, head.dy),
              width: s * 0.05,
              height: s * 0.1,
            ),
            Radius.circular(s * 0.015),
          ),
          Paint()..color = const Color(0xFF2B6CB0),
        );
      case AvatarTier.grinder:
        _drawGear(canvas, Offset(c.dx, c.dy + s * 0.12), s * 0.07, const Color(0xFFECC94B));
      case AvatarTier.based:
        canvas.drawCircle(
          Offset(c.dx + s * 0.12, c.dy + s * 0.08),
          s * 0.04,
          Paint()..color = const Color(0xFF38A169),
        );
        final check = Paint()
          ..color = Colors.white
          ..strokeWidth = s * 0.012
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + s * 0.1, c.dy + s * 0.08)
            ..lineTo(c.dx + s * 0.115, c.dy + s * 0.095)
            ..lineTo(c.dx + s * 0.14, c.dy + s * 0.065),
          check,
        );
      case AvatarTier.chadApprentice:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(c.dx, c.dy + s * 0.02),
              width: s * 0.22,
              height: s * 0.05,
            ),
            Radius.circular(s * 0.02),
          ),
          Paint()..color = const Color(0xFF00B4D8),
        );
      case AvatarTier.chad:
        final shield = Path()
          ..moveTo(c.dx + s * 0.18, c.dy + s * 0.05)
          ..lineTo(c.dx + s * 0.26, c.dy + s * 0.08)
          ..lineTo(c.dx + s * 0.26, c.dy + s * 0.18)
          ..quadraticBezierTo(
            c.dx + s * 0.22,
            c.dy + s * 0.24,
            c.dx + s * 0.18,
            c.dy + s * 0.26,
          )
          ..quadraticBezierTo(
            c.dx + s * 0.14,
            c.dy + s * 0.24,
            c.dx + s * 0.1,
            c.dy + s * 0.18,
          )
          ..lineTo(c.dx + s * 0.1, c.dy + s * 0.08)
          ..close();
        canvas.drawPath(shield, Paint()..color = const Color(0xFFD69E2E));
        canvas.drawPath(
          shield,
          Paint()
            ..color = const Color(0xFF744210)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.01,
        );
      case AvatarTier.sigma:
        canvas.drawPath(
          Path()
            ..moveTo(head.dx - s * 0.2, head.dy + s * 0.05)
            ..quadraticBezierTo(head.dx, head.dy - s * 0.32, head.dx + s * 0.2, head.dy + s * 0.05)
            ..quadraticBezierTo(head.dx, head.dy - s * 0.05, head.dx - s * 0.2, head.dy + s * 0.05),
          Paint()..color = const Color(0xFF1A365D).withValues(alpha: 0.55),
        );
      case AvatarTier.sigmaGrindset:
        final bolt = Path()
          ..moveTo(c.dx + s * 0.2, c.dy - s * 0.05)
          ..lineTo(c.dx + s * 0.14, c.dy + s * 0.05)
          ..lineTo(c.dx + s * 0.18, c.dy + s * 0.05)
          ..lineTo(c.dx + s * 0.12, c.dy + s * 0.18)
          ..lineTo(c.dx + s * 0.22, c.dy + s * 0.04)
          ..lineTo(c.dx + s * 0.17, c.dy + s * 0.04)
          ..close();
        canvas.drawPath(bolt, Paint()..color = const Color(0xFFF6E05E));
      case AvatarTier.alpha:
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.2), s * 0.14, const Color(0xFFFFD700));
      case AvatarTier.gigaChad:
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.2), s * 0.14, const Color(0xFF63B3ED));
        canvas.drawCircle(
          Offset(c.dx - s * 0.16, c.dy + s * 0.1),
          s * 0.035,
          Paint()..color = const Color(0xFF90CDF4),
        );
      case AvatarTier.ultraChad:
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.22), s * 0.15, const Color(0xFFFFD700));
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(c.dx + s * (0.18 + i * 0.02), c.dy - s * (0.05 - i * 0.04)),
            s * 0.015,
            Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.9),
          );
        }
      case AvatarTier.him:
        final flame = Paint()..color = const Color(0xFFFF5722).withValues(alpha: 0.85);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx - s * 0.16, head.dy - s * 0.08),
            width: s * 0.05,
            height: s * 0.09,
          ),
          flame,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx + s * 0.16, head.dy - s * 0.08),
            width: s * 0.05,
            height: s * 0.09,
          ),
          flame,
        );
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.22), s * 0.15, const Color(0xFFFF8A65));
      case AvatarTier.builtDifferent:
        canvas.drawOval(
          Rect.fromCenter(center: c, width: s * 0.72, height: s * 0.28),
          Paint()
            ..color = const Color(0xFF9F7AEA).withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.02,
        );
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.22), s * 0.15, const Color(0xFFB794F4));
      case AvatarTier.finalBoss:
        final horn = Paint()..color = const Color(0xFF553C9A);
        canvas.drawPath(
          Path()
            ..moveTo(head.dx - s * 0.12, head.dy - s * 0.14)
            ..lineTo(head.dx - s * 0.22, head.dy - s * 0.3)
            ..lineTo(head.dx - s * 0.05, head.dy - s * 0.18)
            ..close(),
          horn,
        );
        canvas.drawPath(
          Path()
            ..moveTo(head.dx + s * 0.12, head.dy - s * 0.14)
            ..lineTo(head.dx + s * 0.22, head.dy - s * 0.3)
            ..lineTo(head.dx + s * 0.05, head.dy - s * 0.18)
            ..close(),
          horn,
        );
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.2), s * 0.12, const Color(0xFFE9D8FD));
      case AvatarTier.productivityDemon:
        final horn = Paint()..color = const Color(0xFFFF0055);
        canvas.drawPath(
          Path()
            ..moveTo(head.dx - s * 0.1, head.dy - s * 0.12)
            ..lineTo(head.dx - s * 0.26, head.dy - s * 0.34)
            ..lineTo(head.dx - s * 0.02, head.dy - s * 0.16)
            ..close(),
          horn,
        );
        canvas.drawPath(
          Path()
            ..moveTo(head.dx + s * 0.1, head.dy - s * 0.12)
            ..lineTo(head.dx + s * 0.26, head.dy - s * 0.34)
            ..lineTo(head.dx + s * 0.02, head.dy - s * 0.16)
            ..close(),
          horn,
        );
        _drawCrown(canvas, Offset(head.dx, head.dy - s * 0.2), s * 0.16, const Color(0xFFFFD700));
        canvas.drawCircle(
          Offset(head.dx - s * 0.055, head.dy - s * 0.01),
          s * 0.03,
          Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.45),
        );
        canvas.drawCircle(
          Offset(head.dx + s * 0.055, head.dy - s * 0.01),
          s * 0.03,
          Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.45),
        );
    }
  }

  void _drawCrown(Canvas canvas, Offset center, double w, Color color) {
    final path = Path()
      ..moveTo(center.dx - w, center.dy + w * 0.35)
      ..lineTo(center.dx - w * 0.7, center.dy - w * 0.45)
      ..lineTo(center.dx - w * 0.35, center.dy + w * 0.05)
      ..lineTo(center.dx, center.dy - w * 0.55)
      ..lineTo(center.dx + w * 0.35, center.dy + w * 0.05)
      ..lineTo(center.dx + w * 0.7, center.dy - w * 0.45)
      ..lineTo(center.dx + w, center.dy + w * 0.35)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawGear(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r * 0.55, paint);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            center.dx + math.cos(a) * r * 0.75,
            center.dy + math.sin(a) * r * 0.75,
          ),
          width: r * 0.35,
          height: r * 0.35,
        ),
        paint,
      );
    }
    canvas.drawCircle(center, r * 0.22, Paint()..color = const Color(0xFF2D3748));
  }

  Color _shirtColor() {
    if (_stage >= 17) return const Color(0xFF2D0A1F);
    if (_stage >= 15) return const Color(0xFF2A1A4A);
    if (_stage >= 12) return const Color(0xFF4A1520);
    if (_stage >= 9) return const Color(0xFF1A365D);
    if (_stage >= 8) return const Color(0xFF744210);
    if (_stage >= 5) return const Color(0xFF4A5568);
    if (_stage >= 3) return const Color(0xFFC05621);
    if (_stage == 2) return const Color(0xFF718096);
    if (_stage == 1) return const Color(0xFFE53E3E);
    return const Color(0xFF68D391);
  }

  Color _hairColor() {
    if (_stage >= 16) return const Color(0xFFE9D8FD);
    if (_stage >= 12) return const Color(0xFF1A202C);
    if (_stage >= 9) return const Color(0xFF2D3748);
    if (_stage == 1) return const Color(0xFFD69E2E);
    return const Color(0xFF4A3728);
  }

  @override
  bool shouldRepaint(covariant _AvatarCharacterPainter oldDelegate) {
    return oldDelegate.tier != tier || oldDelegate.accentColors != accentColors;
  }
}
