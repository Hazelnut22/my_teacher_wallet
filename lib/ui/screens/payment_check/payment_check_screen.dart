import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/payment_check_notifier.dart';

class PaymentCheckScreen extends ConsumerWidget {
  const PaymentCheckScreen({super.key});

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
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
      appBar: AppBar(
        title: Text(
          "Payment Check",
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (students) {
          final paidCount =
              students.where((s) => s.payments.any((p) => p.isPaid)).length;
          final total = students.length;

          return Column(
            children: [
              // Month header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.colorSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month,
                        color: colors.colorPrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${_monthName(now.month)} ${now.year}",
                        style: TextStyle(
                          color: colors.colorPrimaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      "$paidCount / $total paid",
                      style: TextStyle(
                        color: colors.colorPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (students.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No students found.",
                      style: TextStyle(color: colors.colorHint),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isPaid = student.payments.isNotEmpty &&
                          student.payments.first.isPaid;

                      return Container(
                        decoration: BoxDecoration(
                          color: colors.colorWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPaid
                                ? Colors.green.withOpacity(0.4)
                                : colors.colorDivider,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
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
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: TextStyle(
                              color: colors.colorPrimaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Grade: ${student.grade}  •  ${student.monthlyFee.toStringAsFixed(0)} MMK",
                            style: TextStyle(
                                color: colors.colorSecondaryText, fontSize: 12),
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              if (student.id != null) {
                                await ref
                                    .read(paymentProvider.notifier)
                                    .togglePayment(student.id!, !isPaid);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green
                                    : colors.colorDivider,
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
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