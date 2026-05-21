import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

String _mmk(double value) {
  final formatted = value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$formatted MMK';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final now = DateTime.now();
    final stateAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (paymentState) {
            // currentMonthStudents already sorted: Paid → Unpaid → Excluded
            final students = paymentState.currentMonthStudents;
            final activeStudents =
                students.where((s) => !s.isExcludedThisMonth).toList();
            final pendingStudents = activeStudents
                .where((s) =>
                    s.payments.isEmpty || !s.payments.first.isPaid)
                .toList();

            final totalExpected = activeStudents.fold<double>(
                0, (sum, s) => sum + s.monthlyFee);
            final totalCollected = activeStudents.fold<double>(0, (sum, s) {
              return sum +
                  s.payments.fold<double>(
                      0, (s2, p) => s2 + (p.isPaid ? p.amountPaid : 0));
            });
            final paidCount = activeStudents
                .where((s) => s.payments.any((p) => p.isPaid))
                .length;
            final progress = totalExpected == 0
                ? 0.0
                : totalCollected / totalExpected;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Text(
                    'My Teacher Wallet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.colorPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_monthName(now.month)} ${now.year}',
                    style: TextStyle(
                        fontSize: 14, color: colors.colorSecondaryText),
                  ),
                  const SizedBox(height: 24),

                  // ── Income card ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.colorPrimary,
                          const Color(0xFF0D5AC4)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.colorPrimary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Collected',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mmk(totalCollected),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withOpacity(0.25),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$paidCount of ${activeStudents.length} students paid',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Stats row ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Expected',
                          value: _mmk(totalExpected),
                          icon: Icons.account_balance_wallet_outlined,
                          color: colors.colorPrimary,
                          bgColor: colors.colorSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Pending',
                          value: _mmk(totalExpected - totalCollected),
                          icon: Icons.pending_actions_outlined,
                          color: colors.colorRedBox,
                          bgColor: colors.colorRedBox.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Pending students ──────────────────────────────────
                  if (pendingStudents.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Pending Students',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.colorPrimaryText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.colorRedBox.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pendingStudents.length}',
                            style: TextStyle(
                              color: colors.colorRedBox,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pendingStudents.map((student) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.colorWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    colors.colorRedBox.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    colors.colorRedBox.withOpacity(0.1),
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: colors.colorRedBox,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: TextStyle(
                                        color: colors.colorPrimaryText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Grade: ${student.grade}',
                                      style: TextStyle(
                                          color: colors.colorSecondaryText,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _mmk(student.monthlyFee),
                                style: TextStyle(
                                  color: colors.colorRedBox,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── This month (Paid → Excluded) ──────────────────────
                  Row(
                    children: [
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.colorPrimaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${students.length} student${students.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            color: colors.colorSecondaryText,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (students.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No students yet.\nAdd students from the Students tab.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.colorHint),
                        ),
                      ),
                    )
                  else
                    // Sorted: Paid → Unpaid → Excluded (from notifier)
                    ...students.map((student) {
                      final isPaid =
                          student.payments.any((p) => p.isPaid);
                      final isExcluded = student.isExcludedThisMonth;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.colorWhite,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: colors.colorDivider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                student.name,
                                style: TextStyle(
                                  color: isExcluded
                                      ? colors.colorGray
                                      : colors.colorPrimaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isExcluded
                                    ? colors.colorGray.withOpacity(0.1)
                                    : isPaid
                                        ? Colors.green.withOpacity(0.1)
                                        : colors.colorRedBox
                                            .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isExcluded
                                    ? 'Excluded'
                                    : isPaid
                                        ? 'Paid'
                                        : 'Pending',
                                style: TextStyle(
                                  color: isExcluded
                                      ? colors.colorGray
                                      : isPaid
                                          ? Colors.green
                                          : colors.colorRedBox,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}