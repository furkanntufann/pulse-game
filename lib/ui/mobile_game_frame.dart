import 'dart:math';

import 'package:flutter/material.dart';

/// Oyun alanini ekranin buyuk bolumunu kaplayacak sekilde ortalar (9:16).
class MobileGameFrame extends StatelessWidget {
  const MobileGameFrame({super.key, required this.child});

  final Widget child;

  static const double _aspectWidth = 9;
  static const double _aspectHeight = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth * 0.98;
        final maxH = constraints.maxHeight * 0.98;

        var width = maxW;
        var height = width * _aspectHeight / _aspectWidth;

        if (height > maxH) {
          height = maxH;
          width = height * _aspectWidth / _aspectHeight;
        }

        final isLetterboxed =
            width < constraints.maxWidth - 8 || height < constraints.maxHeight - 8;

        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A12),
              borderRadius: BorderRadius.circular(isLetterboxed ? 20 : 0),
              border: isLetterboxed
                  ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        );
      },
    );
  }
}
