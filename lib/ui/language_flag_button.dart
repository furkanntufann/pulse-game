import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_locale.dart';

class LanguageFlagButton extends StatelessWidget {
  const LanguageFlagButton({
    super.key,
    required this.locale,
    required this.flagEmoji,
    required this.isSelected,
    required this.onTap,
  });

  final AppLocale locale;
  final String flagEmoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5C8).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5C8)
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.6 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 5),
            Text(
              locale == AppLocale.tr ? 'TR' : 'EN',
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E5C8) : Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
