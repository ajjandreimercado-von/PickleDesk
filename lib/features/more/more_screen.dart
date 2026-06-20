import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Reservations', sub: 'Manage bookings', path: '/reservations', icon: Icons.calendar_month, color: AppTheme.primary),
      (label: 'Expenses', sub: 'Spending tracker', path: '/expenses', icon: Icons.account_balance_wallet, color: Color(0xFFFFB4AB)),
      (label: 'Analytics', sub: 'Performance insights', path: '/analytics', icon: Icons.show_chart, color: AppTheme.text2),
      (label: 'Settings', sub: 'Preferences & backup', path: '/settings', icon: Icons.settings, color: AppTheme.text3),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('More', style: GoogleFonts.montserrat(
            color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
        backgroundColor: Color(0xE0111410),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 600 ? 2 : 1;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: cols == 2 ? 2.8 : 3.5,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => context.go(item.path),
                child: PDCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.label,
                                style: GoogleFonts.montserrat(
                                    color: AppTheme.text1,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                            Text(item.sub,
                                style: GoogleFonts.inter(
                                    color: AppTheme.text3, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.text2),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
