import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/utils/number_formatter.dart';

class ChecklistCard extends ConsumerWidget {
  final StudentEntity student;
  const ChecklistCard({super.key, required this.student});

  void _showManageSheet(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isExcluded = student.isExcludedThisMonth;
    final paymentId =
        student.payments.isNotEmpty ? student.payments.first.id : null;
    final actionColor =
        isExcluded ? colors.colorSuccess : colors.colorRedBox;

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
                style: context.appFonts.headlineSmall()?.copyWith(
                color: colors.colorPrimaryText,
                fontWeight: FontWeight.bold,
              ),),
            Text('Grade: ${student.grade}',
                style: context.appFonts.bodySmall()
                  ?.copyWith(color: colors.colorSecondaryText),),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExcluded
                      ? Icons.person_add_outlined
                      : Icons.person_remove_outlined,
                  color:
                      actionColor,
                ),
              ),
              title: Text(
                isExcluded
                    ? 'Include this student this month'
                    : 'Exclude this student this month',
                style: context.appFonts.titleLarge()?.copyWith(
                  color: actionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isExcluded
                    ? 'Add back to this month\'s payment list'
                    : 'Won\'t count towards this month\'s total',
                style: context.appFonts.bodySmall()
                    ?.copyWith(color: colors.colorSecondaryText),
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

    final leadingColor = isExcluded
        ? colors.colorGray
        : isPaid
            ? colors.colorSuccess
            : colors.colorPrimary;

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
                  ? colors.colorSuccess.withOpacity(0.4)
                  : colors.colorDivider,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: leadingColor.withOpacity(0.1),
          child: Text(
            student.name[0].toUpperCase(),
            style: context.appFonts.bodyMedium()?.copyWith(
              color: leadingColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style:  context.appFonts.titleLarge()?.copyWith(
            color: isExcluded ? colors.colorGray : colors.colorPrimaryText,
            fontWeight: FontWeight.w600,
            decoration:
                isExcluded ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          isExcluded
              ? 'Excluded this month'
              : 'Grade: ${student.grade}  •  ${NumberFormatter.mmk(student.monthlyFee)}',
          style: context.appFonts.bodySmall()
              ?.copyWith(color: colors.colorSecondaryText),
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
                    color: isPaid
                        ? colors.colorSuccess
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
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: colors.colorWhite,
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
