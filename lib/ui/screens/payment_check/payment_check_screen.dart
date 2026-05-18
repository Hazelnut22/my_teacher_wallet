import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_check_notifier.dart';
import 'package:my_teacher_wallet/ui/screens/student/widgets/student_card.dart';

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
    final stateAsync = ref.watch(paymentCheckProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Payment Check',
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (checkState) {
          final students = checkState.students;
          final paidCount = students
              .where((s) => s.payments.isNotEmpty && s.payments.first.isPaid)
              .length;
          final totalExpected = students.fold<double>(
              0, (sum, s) => sum + s.monthlyFee);
          final totalCollected = students.fold<double>(0, (sum, s) {
            return sum +
                s.payments.fold<double>(
                    0, (s2, p) => s2 + (p.isPaid ? p.amountPaid : 0));
          });

          return Column(
            children: [
              // ── Month filter + summary ──────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(16),
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
                              value: checkState.selectedMonth,
                              isDense: true,
                              style: TextStyle(
                                color: colors.colorPrimaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              dropdownColor: colors.colorWhite,
                              borderRadius: BorderRadius.circular(12),
                              items: checkState.availableMonths
                                  .map((month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(_formatMonth(month)),
                                      ))
                                  .toList(),
                              onChanged: checkState.isLoading
                                  ? null
                                  : (month) {
                                      if (month != null) {
                                        ref
                                            .read(paymentCheckProvider.notifier)
                                            .selectMonth(month);
                                      }
                                    },
                            ),
                          ),
                        ),
                        if (checkState.isLoading)
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
                        _SummaryChip(
                          label: 'Paid',
                          value: '$paidCount/${students.length}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Collected',
                          value:
                              '${totalCollected.toStringAsFixed(0)} MMK',
                          color: colors.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Pending',
                          value:
                              '${(totalExpected - totalCollected).toStringAsFixed(0)} MMK',
                          color: colors.colorRedBox,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Student checklist ───────────────────────────────────────
              if (students.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No students found.',
                      style: TextStyle(color: colors.colorHint),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return StudentCard(student: students[index], isChecklist: true,);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.8), fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
