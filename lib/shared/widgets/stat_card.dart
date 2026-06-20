import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Stat card matching frontend StatCard — label, large value, optional sub-text
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final bool subPositive;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.subPositive = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  color: AppTheme.text2,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  color: valueColor ?? AppTheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
          if (sub != null)
            Text(
              sub!,
              style: GoogleFonts.inter(
                color: subPositive ? AppTheme.primaryDeep : AppTheme.loseText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
