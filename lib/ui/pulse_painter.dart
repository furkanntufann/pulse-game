import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../game/pulse_engine.dart';
import '../models/hit_result.dart';

class PulsePainter extends CustomPainter {
  PulsePainter({
    required this.engine,
    required this.hitFlash,
    required this.hitResult,
    required this.pulseTime,
  });

  final PulseEngine engine;
  final double hitFlash;
  final HitResult? hitResult;
  final double pulseTime;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final targetR = engine.targetRadius;

    // Arka plan nabız ızgarası
    _drawBackground(canvas, size, center);

    // Hedef halka (tatlı nokta)
    final targetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF00E5C8).withValues(alpha: 0.55 + 0.25 * sin(pulseTime * 3));
    canvas.drawCircle(center, targetR, targetPaint);

    final innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0xFF00E5C8).withValues(alpha: 0.08);
    canvas.drawCircle(center, targetR, innerGlow);

    // Perfect / good bölgeleri (ince)
    for (final w in [14.0, 28.0]) {
      final zonePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: w == 14 ? 0.06 : 0.03);
      canvas.drawCircle(center, targetR - w, zonePaint);
      canvas.drawCircle(center, targetR + w, zonePaint);
    }

    // Aktif genişleyen halka
    final pulse = engine.activePulse;
    if (pulse != null) {
      final color = pulse.isDecoy
          ? const Color(0xFFFF6B9D)
          : const Color(0xFF7C4DFF);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pulse.isDecoy ? 2.5 : 4
        ..color = color.withValues(alpha: pulse.isDecoy ? 0.45 : 0.9);
      canvas.drawCircle(center, pulse.radius, ringPaint);

      if (!pulse.isDecoy) {
        final trailPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.25);
        canvas.drawCircle(center, pulse.radius - 10, trailPaint);
      }
    }

    // Merkez çekirdek
    final coreRadius = 18 + sin(pulseTime * 4) * 2;
    final coreGradient = RadialGradient(
      colors: [
        const Color(0xFFFF4081),
        const Color(0xFF7C4DFF),
      ],
    );
    final corePaint = Paint()
      ..shader = coreGradient.createShader(
        Rect.fromCircle(center: center, radius: coreRadius),
      );
    canvas.drawCircle(center, coreRadius, corePaint);

    // Hit flash
    if (hitFlash > 0 && hitResult != null) {
      final flashColor = switch (hitResult!) {
        HitResult.perfect => const Color(0xFF00E5C8),
        HitResult.good => const Color(0xFFFFD54F),
        HitResult.miss => const Color(0xFFFF5252),
        HitResult.trap => const Color(0xFFFF6B9D),
      };
      final flashPaint = Paint()
        ..color = flashColor.withValues(alpha: hitFlash * 0.35);
      canvas.drawCircle(center, targetR + 40 * (1 - hitFlash), flashPaint);
    }
  }

  void _drawBackground(Canvas canvas, Size size, Offset center) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, i * 55.0, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PulsePainter oldDelegate) => true;
}
