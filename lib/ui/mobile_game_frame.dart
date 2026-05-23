import 'dart:math';

import 'package:flutter/material.dart';

/// Oyunu mobil telefon oranında (9:16) gösterir; geniş ekranda ortalanır.
class MobileGameFrame extends StatelessWidget {
  const MobileGameFrame({super.key, required this.child});

  final Widget child;

  static const double _maxPhoneWidth = 430;
  static const double _aspectWidth = 9;
  static const double _aspectHeight = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = min(constraints.maxWidth, _maxPhoneWidth);
        final maxH = constraints.maxHeight;

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
              borderRadius: BorderRadius.circular(isLetterboxed ? 28 : 0),
              border: isLetterboxed
                  ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                  : null,
              boxShadow: isLetterboxed
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 48,
                        spreadRadius: 4,
                      ),
                    ]
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
