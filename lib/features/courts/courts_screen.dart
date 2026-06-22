import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import 'court_providers.dart';

class CourtsScreen extends ConsumerWidget {
  const CourtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courts = ref.watch(courtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('My locations',
                style: GoogleFonts.inter(
                    color: AppTheme.text2, fontSize: 12)),
            Text('Courts',
                style: GoogleFonts.montserrat(
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w700,
                    fontSize: 22)),
          ],
        ),
        backgroundColor: Color(0xE0111410),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth > 700 ? 2 : 1;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: courts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Center(
                          child: Column(children: [
                            Icon(Icons.sports_tennis,
                                size: 48, color: AppTheme.text3),
                            const SizedBox(height: 12),
                            Text('No courts added yet',
                                style: GoogleFonts.inter(
                                    color: AppTheme.text3, fontSize: 14)),
                          ]),
                        ),
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final court = courts[i];
                          return PDCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: court.isFavorite == true
                                            ? AppTheme.primaryDark
                                            : AppTheme.surface2,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.sports_tennis,
                                          color: court.isFavorite == true
                                              ? AppTheme.primary
                                              : AppTheme.text2),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(court.name,
                                                    style: GoogleFonts
                                                        .montserrat(
                                                      color: AppTheme.text1,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 17,
                                                    )),
                                              ),
                                              if (court.isFavorite == true)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryDark,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text('Favorite',
                                                      style: GoogleFonts.inter(
                                                          color: AppTheme.primary,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            '${court.isIndoor ? 'Indoor' : 'Outdoor'} · ${court.surfaceType}',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.text2,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                    color: AppTheme.border.withValues(alpha: 0.6),
                                    height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('PLAYED',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.text3,
                                                fontSize: 10,
                                                letterSpacing: 0.8)),
                                        Text('0x',
                                            style: GoogleFonts.montserrat(
                                                color: AppTheme.text1,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18)),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('LAST VISIT',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.text3,
                                                fontSize: 10,
                                                letterSpacing: 0.8)),
                                        Text('—',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.text2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(courtListProvider.notifier)
                                          .deleteCourt(court.id),
                                      child: Icon(Icons.delete_outline,
                                          color: AppTheme.loseText
                                              .withValues(alpha: 0.7),
                                          size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: courts.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: cols == 2 ? 1.4 : 1.8,
                      ),
                    ),
            ),

            // Dashed Add Court button
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () => context.push('/add-court'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.border,
                          style: BorderStyle.solid,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('+',
                            style: GoogleFonts.montserrat(
                                color: AppTheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text('Add Court',
                            style: GoogleFonts.inter(
                                color: AppTheme.text2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      }),
    );
  }
}
