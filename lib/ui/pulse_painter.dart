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

    // Hedef halka (turkuaz nokta)
    final targetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF00E5C8).withValues(alpha: 0.55 + 0.25 * sin(pulseTime * 3));
    canvas.drawCircle(center, targetR, targetPaint);

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

  @override
  bool shouldRepaint(covariant PulsePainter oldDelegate) => true;
}
