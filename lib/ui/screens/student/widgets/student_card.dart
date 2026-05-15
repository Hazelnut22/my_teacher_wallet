import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/payment_check_notifier.dart';

class StudentCard extends ConsumerWidget {
  final StudentEntity student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isPaid = student.payments.isNotEmpty && student.payments.first.isPaid;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? Colors.green.withOpacity(0.4) : colors.colorDivider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.pushNamed(Routes.studentDetail.name, extra: student);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Initial Circle
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    isPaid ? Colors.green.withOpacity(0.1) : colors.colorSecondary,
                child: Text(
                  student.name[0].toUpperCase(),
                  style: TextStyle(
                    color: isPaid ? Colors.green : colors.colorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name and Grade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        color: colors.colorPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Grade: ${student.grade}",
                      style:
                          TextStyle(color: colors.colorSecondaryText, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${student.monthlyFee.toStringAsFixed(0)} MMK",
                      style: TextStyle(
                        color: colors.colorPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Payment toggle
              GestureDetector(
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
                    color: isPaid ? Colors.green : colors.colorDivider,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        isPaid ? Alignment.centerRight : Alignment.centerLeft,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}