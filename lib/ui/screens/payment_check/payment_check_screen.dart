import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

String _mmk(double value) {
  final formatted = value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$formatted MMK';
}

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
    final stateAsync = ref.watch(paymentProvider);

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
        actions: [
          IconButton(
            icon: Icon(Icons.summarize_outlined, color: colors.colorPrimary),
            onPressed: () => context.pushNamed(Routes.reports.name),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
                          style: TextStyle(
                            color: colors.colorPrimaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _YearStatItem(
                          label: 'Collected',
                          value: _mmk(stats.totalCollectedYear),
                          color: Colors.green,
                        ),
                        _YearStatItem(
                          label: 'Monthly Avg',
                          value: _mmk(stats.monthlyAverage),
                          color: colors.colorPrimary,
                        ),
                        _YearStatItem(
                          label: 'Rate',
                          value:
                              '${(stats.collectionRate * 100).toStringAsFixed(1)}%',
                          color: stats.collectionRate >= 0.8
                              ? Colors.green
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
                              style: TextStyle(
                                color: colors.colorPrimaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              dropdownColor: colors.colorWhite,
                              borderRadius: BorderRadius.circular(12),
                              items: paymentState.availableMonths
                                  .map((month) => DropdownMenuItem(
                                        value: month,
                                        child:
                                            Text(_formatMonth(month)),
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
                        _SummaryChip(
                          label: 'Paid',
                          value: '$paidCount/${activeStudents.length}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Collected',
                          value: _mmk(totalCollected),
                          color: colors.colorPrimary,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Pending',
                          value: _mmk(totalExpected - totalCollected),
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
                    child: Text('No students found.',
                        style: TextStyle(color: colors.colorHint)),
                  ),
                )
              else
                ...students.map((student) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChecklistCard(student: student),
                    )),
            ],
          );
        },
      ),
    );
  }
}

// ── Checklist card ─────────────────────────────────────────────────────────────

class _ChecklistCard extends ConsumerWidget {
  final StudentEntity student;
  const _ChecklistCard({required this.student});

  void _showManageSheet(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isExcluded = student.isExcludedThisMonth;
    final paymentId =
        student.payments.isNotEmpty ? student.payments.first.id : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: colors.colorWhite,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.colorGray.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(student.name,
                style: TextStyle(
                    color: colors.colorPrimaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('Grade: ${student.grade}',
                style: TextStyle(
                    color: colors.colorSecondaryText, fontSize: 13)),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isExcluded
                      ? Colors.green.withOpacity(0.1)
                      : colors.colorRedBox.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExcluded
                      ? Icons.person_add_outlined
                      : Icons.person_remove_outlined,
                  color:
                      isExcluded ? Colors.green : colors.colorRedBox,
                ),
              ),
              title: Text(
                isExcluded
                    ? 'Include this student this month'
                    : 'Exclude this student this month',
                style: TextStyle(
                  color: isExcluded ? Colors.green : colors.colorRedBox,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isExcluded
                    ? 'Add back to this month\'s payment list'
                    : 'Won\'t count towards this month\'s total',
                style: TextStyle(
                    color: colors.colorSecondaryText, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (paymentId != null) {
                  await ref
                      .read(paymentProvider.notifier)
                      .toggleExcluded(paymentId, !isExcluded);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isExcluded = student.isExcludedThisMonth;
    final hasPayment = student.payments.isNotEmpty;
    final isPaid =
        hasPayment && student.payments.first.isPaid && !isExcluded;
    final paymentId = hasPayment ? student.payments.first.id : null;

    return Container(
      decoration: BoxDecoration(
        color: isExcluded
            ? colors.colorGray.withOpacity(0.06)
            : colors.colorWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExcluded
              ? colors.colorGray.withOpacity(0.3)
              : isPaid
                  ? Colors.green.withOpacity(0.4)
                  : colors.colorDivider,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isExcluded
              ? colors.colorGray.withOpacity(0.15)
              : isPaid
                  ? Colors.green.withOpacity(0.1)
                  : colors.colorSecondary,
          child: Text(
            student.name[0].toUpperCase(),
            style: TextStyle(
              color: isExcluded
                  ? colors.colorGray
                  : isPaid
                      ? Colors.green
                      : colors.colorPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: TextStyle(
            color:
                isExcluded ? colors.colorGray : colors.colorPrimaryText,
            fontWeight: FontWeight.w600,
            decoration:
                isExcluded ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          isExcluded
              ? 'Excluded this month'
              : 'Grade: ${student.grade}  •  ${_mmk(student.monthlyFee)}',
          style:
              TextStyle(color: colors.colorSecondaryText, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showManageSheet(context, ref),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.more_vert,
                    color: colors.colorGray, size: 20),
              ),
            ),
            const SizedBox(width: 4),
            if (!isExcluded && paymentId != null)
              GestureDetector(
                onTap: () => ref
                    .read(paymentProvider.notifier)
                    .togglePayment(paymentId, !isPaid, student.monthlyFee),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green : colors.colorDivider,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isPaid
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              )
            else if (isExcluded)
              Icon(Icons.remove_circle_outline,
                  color: colors.colorGray, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _YearStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _YearStatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: context.appColors.colorSecondaryText,
                  fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}