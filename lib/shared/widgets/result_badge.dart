import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// W / L / D result badge — circular colored indicator
class ResultBadge extends StatelessWidget {
  final String result; // "W" | "L" | "D"
  final double size;

  const ResultBadge({super.key, required this.result, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final Color bg = result == 'W'
        ? AppTheme.winBg
        : result == 'L'
            ? AppTheme.loseBg
            : AppTheme.surface3;
    final Color fg = result == 'W'
        ? AppTheme.primary
        : result == 'L'
            ? AppTheme.loseText
            : AppTheme.text2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        result,
        style: GoogleFonts.montserrat(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
