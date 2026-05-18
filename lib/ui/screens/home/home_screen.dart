import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final now = DateTime.now();
    final studentsAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      body: SafeArea(
        child: studentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
          data: (students) {
            final totalExpected = students.fold<double>(
              0,
              (sum, s) => sum + s.monthlyFee,
            );
            final totalCollected = students.fold<double>(0, (sum, s) {
              final paid = s.payments
                  .where((p) => p.isPaid)
                  .fold<double>(0, (s2, p) => s2 + p.amountPaid);
              return sum + paid;
            });
            final paidCount = students
                .where((s) => s.payments.any((p) => p.isPaid))
                .length;
            final progress = totalExpected == 0
                ? 0.0
                : totalCollected / totalExpected;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "My Teacher Wallet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.colorPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_monthName(now.month)} ${now.year}",
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.colorSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main income card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.colorPrimary, const Color(0xFF0D5AC4)],
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
                          "Total Collected",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${totalCollected.toStringAsFixed(0)} MMK",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$paidCount of ${students.length} students paid",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "Expected",
                          value: "${totalExpected.toStringAsFixed(0)} MMK",
                          icon: Icons.account_balance_wallet_outlined,
                          color: colors.colorPrimary,
                          bgColor: colors.colorSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: "Pending",
                          value:
                              "${(totalExpected - totalCollected).toStringAsFixed(0)} MMK",
                          icon: Icons.pending_actions_outlined,
                          color: colors.colorRedBox,
                          bgColor: colors.colorRedBox.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Student breakdown
                  Text(
                    "This Month",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.colorPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (students.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "No students yet.\nAdd students from the Students tab.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.colorHint),
                        ),
                      ),
                    )
                  else
                    ...students.map((student) {
                      final isPaid = student.payments.any((p) => p.isPaid);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.colorWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.colorDivider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isPaid
                                  ? Colors.green.withOpacity(0.1)
                                  : colors.colorSecondary,
                              child: Text(
                                student.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: isPaid
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
                                  color: colors.colorPrimaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.withOpacity(0.1)
                                    : colors.colorRedBox.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isPaid ? "Paid" : "Pending",
                                style: TextStyle(
                                  color: isPaid
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
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}