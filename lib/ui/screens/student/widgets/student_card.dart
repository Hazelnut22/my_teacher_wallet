import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

class StudentCard extends ConsumerWidget {
  final StudentEntity student;
  final bool isChecklist;

  const StudentCard({super.key, required this.student, required this.isChecklist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final fonts = context.appFonts;
    final hasPayment = student.payments.isNotEmpty;
    final isPaid = hasPayment && student.payments.first.isPaid;
    final paymentId = hasPayment ? student.payments.first.id : null;
    final avatarColor = isPaid ? colors.colorSuccess : colors.colorPrimary;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? colors.colorSuccess.withOpacity(0.4)
              : colors.colorDivider,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.colorPrimaryText.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            context.pushNamed(Routes.studentDetail.name, extra: student),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: isPaid
                    ? colors.colorSuccess
                    : colors.colorSecondary,
                child: Text(
                  student.name[0].toUpperCase(),
                  style: fonts.bodyMedium()?.copyWith(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name / grade / fee
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: fonts.titleLarge()?.copyWith(
                        color: colors.colorPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Grade: ${student.grade}',
                      style: fonts.bodySmall()?.copyWith(
                        color: colors.colorSecondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.monthlyFee.toStringAsFixed(0)} MMK',
                      style: fonts.bodySmall()?.copyWith(
                        color: colors.colorPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Payment toggle
              if (paymentId != null && isChecklist)
                GestureDetector(
                  onTap: () => ref
                      .read(paymentProvider.notifier)
                      .togglePayment(paymentId, !isPaid, student.monthlyFee),
                  child: _Toggle(isPaid: isPaid),
                )
              else
                Icon(Icons.hourglass_empty,
                    size: 18, color: colors.colorHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool isPaid;

  const _Toggle({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 52,
      height: 30,
      decoration: BoxDecoration(
        color: isPaid ? context.appColors.colorSuccess : context.appColors.colorDivider,
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
          decoration: BoxDecoration(
            color: context.appColors.colorWhite,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}