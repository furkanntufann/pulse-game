import 'package:flutter/material.dart';

/// Oyun alanini tum ekrani kaplayacak sekilde doldurur.
class MobileGameFrame extends StatelessWidget {
  const MobileGameFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ColoredBox(
            color: const Color(0xFF0A0A12),
            child: child,
          ),
        );
      },
    );
  }
}
