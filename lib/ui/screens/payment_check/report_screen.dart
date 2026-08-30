import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/highlight_card.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/mini_stat.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/section_tile.dart';
import 'package:my_teacher_wallet/ui/widgets/error_state_view.dart';
import 'package:my_teacher_wallet/utils/number_formatter.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final fonts = context.appFonts;
    final stateAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Yearly Report',
          style: fonts.appBarTitle()
              ?.copyWith(color: colors.colorPrimaryText),
        ),
        backgroundColor: colors.colorNavBarBg,
        foregroundColor: colors.colorPrimaryText,
        elevation: 0,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(paymentProvider)),
        data: (paymentState) {
          final report = paymentState.reportData;
          if (report.monthlyBreakdown.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                      size: 64, color: colors.colorHint),
                  const SizedBox(height: 16),
                  Text('No data for ${report.year} yet.',
                      style: fonts.headlineSmall()
                        ?.copyWith(color: colors.colorPrimaryText),),
                  const SizedBox(height: 8),
                  Text('Start adding students and tracking payments.',
                      style: fonts.bodySmall()
                        ?.copyWith(color: colors.colorHint),),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Year header ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.colorPrimary,
                      const Color(0xFF0D5AC4)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.year} Summary',
                      style: fonts.bodySmall()?.copyWith(
                        color: colors.colorWhite.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      NumberFormatter.mmk(report.totalCollected),
                      style: fonts.headlineLarge()?.copyWith(
                        color: colors.colorWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ${NumberFormatter.mmk(report.totalExpected)} expected',
                      style: fonts.bodySmall()?.copyWith(
                        color: colors.colorWhite.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: report.collectionRate,
                        minHeight: 6,
                        backgroundColor: colors.colorWhite.withOpacity(0.25),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            colors.colorWhite),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${report.totalStudents} student${report.totalStudents == 1 ? '' : 's'}',
                          style: fonts.bodySmall()?.copyWith(
                            color: colors.colorWhite.withOpacity(0.85),
                          ),
                        ),
                        Text(
                          '${(report.collectionRate * 100).toStringAsFixed(1)}% collected',
                          style: fonts.bodySmall()?.copyWith(
                            color: colors.colorWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Highlights ─────────────────────────────────────────────
              SectionTitle(title: 'Highlights'),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (report.bestMonth != null)
                    Expanded(
                      child: HighlightCard(
                        label: 'Best Month',
                        value: _monthNames[
                            report.bestMonth!.month.month - 1],
                        sub:
                            '${(report.bestMonth!.collectionRate * 100).toStringAsFixed(0)}% collected',
                        icon: Icons.trending_up,
                        color: colors.colorSuccess,
                      ),
                    ),
                  if (report.bestMonth != null &&
                      report.worstMonth != null)
                    const SizedBox(width: 12),
                  if (report.worstMonth != null &&
                      report.worstMonth != report.bestMonth)
                    Expanded(
                      child: HighlightCard(
                        label: 'Lowest Month',
                        value: _monthNames[
                            report.worstMonth!.month.month - 1],
                        sub:
                            '${(report.worstMonth!.collectionRate * 100).toStringAsFixed(0)}% collected',
                        icon: Icons.trending_down,
                        color: colors.colorRedBox,
                      ),
                    ),
                ],
              ),
              if (report.mostConsistentStudent != null) ...[
                const SizedBox(height: 12),
                HighlightCard(
                  label: 'Most Consistent Student',
                  value: report.mostConsistentStudent!.name,
                  sub:
                      '${report.mostConsistentStudent!.monthsPaid} months paid  •  ${(report.mostConsistentStudent!.attendanceRate * 100).toStringAsFixed(0)}% rate',
                  icon: Icons.star_outline,
                  color: colors.colorWarning,
                  fullWidth: true,
                ),
              ],

              const SizedBox(height: 20),

              // ── Monthly trend ──────────────────────────────────────────
              SectionTitle(title: 'Monthly Trend'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.colorWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.colorDivider),
                ),
                child: Column(
                  children: report.monthlyBreakdown.map((entry) {
                    final rate = entry.collectionRate;
                    final barColor = rate >= 0.8
                        ? colors.colorSuccess
                        : rate >= 0.5
                            ? colors.colorPrimary
                            : colors.colorRedBox;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              _monthNames[entry.month.month - 1],
                              style: fonts.bodySmall()?.copyWith(
                                color: colors.colorSecondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: rate,
                                    minHeight: 10,
                                    backgroundColor:
                                        barColor.withOpacity(0.15),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            barColor),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${entry.paidCount} paid  •  ${entry.unpaidCount} unpaid'
                                  '${entry.excludedCount > 0 ? '  •  ${entry.excludedCount} excluded' : ''}',
                                  style: fonts.bodySmall()?.copyWith(
                                    color: colors.colorSecondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 42,
                            child: Text(
                              '${(rate * 100).toStringAsFixed(0)}%',
                              textAlign: TextAlign.right,
                              style: fonts.bodySmall()?.copyWith(
                                color: barColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Per-student breakdown ──────────────────────────────────
              SectionTitle(
                  title: 'Student Breakdown'),
              const SizedBox(height: 8),
              ...report.studentBreakdown.map((entry) {
                final rate = entry.attendanceRate;
                final rateColor = rate >= 0.8
                    ? colors.colorSuccess
                    : rate >= 0.5
                        ? colors.colorPrimary
                        : colors.colorRedBox;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.colorDivider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                rateColor.withOpacity(0.1),
                            child: Text(
                              entry.name[0].toUpperCase(),
                              style: fonts.bodySmall()?.copyWith(
                                color: rateColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(entry.name,
                                    style: fonts.titleLarge()?.copyWith(
                                    color: colors.colorPrimaryText,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                Text('Grade: ${entry.grade}',
                                    style: fonts.bodySmall()?.copyWith(
                                    color: colors.colorSecondaryText,
                                  ),),
                              ],
                            ),
                          ),
                          Text(
                            NumberFormatter.mmk(entry.totalPaid),
                            style: fonts.bodySmall()?.copyWith(
                              color: rateColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          MiniStat(
                              label: 'Paid',
                              value: '${entry.monthsPaid}mo',
                              color: colors.colorSuccess),
                          MiniStat(
                              label: 'Unpaid',
                              value: '${entry.monthsUnpaid}mo',
                              color: colors.colorRedBox),
                          if (entry.monthsExcluded > 0)
                            MiniStat(
                                label: 'Excluded',
                                value: '${entry.monthsExcluded}mo',
                                color: colors.colorGray),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(rate * 100).toStringAsFixed(0)}% rate',
                                  style: fonts.bodySmall()?.copyWith(
                                    color: rateColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 6,
                          backgroundColor: rateColor.withOpacity(0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(rateColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}