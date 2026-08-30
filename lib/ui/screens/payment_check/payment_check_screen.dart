import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/checklist_card.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/summary_chip.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/widgets/year_stat_item.dart';
import 'package:my_teacher_wallet/ui/widgets/error_state_view.dart';
import 'package:my_teacher_wallet/utils/number_formatter.dart';

class PaymentCheckScreen extends ConsumerWidget {
  const PaymentCheckScreen({super.key});

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatMonth(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final fonts = context.appFonts;
    final stateAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Payment Check',
          style: fonts.appBarTitle()
              ?.copyWith(color: colors.colorPrimaryText),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.summarize_outlined, color: colors.colorPrimary),
            onPressed: () => context.pushNamed(Routes.reports.name),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(paymentProvider)),
        data: (paymentState) {
          // checkStudents already sorted: Unpaid → Paid → Excluded
          final students = paymentState.checkStudents;
          final stats = paymentState.yearlyStats;
          final activeStudents =
              students.where((s) => !s.isExcludedThisMonth).toList();
          final paidCount = activeStudents
              .where((s) =>
                  s.payments.isNotEmpty && s.payments.first.isPaid)
              .length;
          final totalExpected = activeStudents.fold<double>(
              0, (sum, s) => sum + s.monthlyFee);
          final totalCollected = activeStudents.fold<double>(0, (sum, s) {
            return sum +
                s.payments.fold<double>(
                    0, (s2, p) => s2 + (p.isPaid ? p.amountPaid : 0));
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Yearly stats ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.colorWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.colorDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart,
                            color: colors.colorPrimary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${DateTime.now().year} Overview',
                          style: fonts.titleLarge()?.copyWith(
                            color: colors.colorPrimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        YearStatItem(
                          label: 'Collected',
                          value: NumberFormatter.mmk(stats.totalCollectedYear),
                          color: Colors.green,
                        ),
                        YearStatItem(
                          label: 'Monthly Avg',
                          value: NumberFormatter.mmk(stats.monthlyAverage),
                          color: colors.colorPrimary,
                        ),
                        YearStatItem(
                          label: 'Rate',
                          value:
                              '${(stats.collectionRate * 100).toStringAsFixed(1)}%',
                          color: stats.collectionRate >= 0.8
                              ? colors.colorSuccess
                              : colors.colorRedBox,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Month dropdown ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.colorSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: colors.colorPrimary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateTime>(
                              value: paymentState.selectedMonth,
                              isDense: true,
                              style: fonts.titleLarge()?.copyWith(
                                color: colors.colorPrimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              dropdownColor: colors.colorWhite,
                              borderRadius: BorderRadius.circular(12),
                              items: paymentState.availableMonths
                                  .map((month) => DropdownMenuItem(
                                        value: month,
                                        child:
                                            Text(
                                              _formatMonth(month),
                                              style:
                                              fonts.titleLarge()?.copyWith(
                                            color: colors.colorPrimaryText,
                                          ),),
                                      ))
                                  .toList(),
                              onChanged: paymentState.isCheckLoading
                                  ? null
                                  : (month) {
                                      if (month != null) {
                                        ref
                                            .read(
                                                paymentProvider.notifier)
                                            .selectMonth(month);
                                      }
                                    },
                            ),
                          ),
                        ),
                        if (paymentState.isCheckLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.colorPrimary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SummaryChip(
                          label: 'Paid',
                          value: '$paidCount/${activeStudents.length}',
                          color: colors.colorSuccess,
                        ),
                        const SizedBox(width: 8),
                        SummaryChip(
                          label: 'Collected',
                          value: NumberFormatter.mmk(totalCollected),
                          color: colors.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        SummaryChip(
                          label: 'Pending',
                          value: NumberFormatter.mmk(totalExpected - totalCollected),
                          color: colors.colorRedBox,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Student checklist (Unpaid → Paid → Excluded) ──────────
              if (students.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No students found',
                        style: fonts.bodyMedium()
                          ?.copyWith(color: colors.colorHint),)
                  ),
                )
              else
                ...students.map((student) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ChecklistCard(student: student),
                    )),
            ],
          );
        },
      ),
    );
  }
}