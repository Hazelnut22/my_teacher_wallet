import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/student/widgets/student_swipe_bg.dart';
import 'package:my_teacher_wallet/utils/number_formatter.dart';

class SwipableStudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SwipableStudentCard({super.key, 
    required this.student,
    required this.onEdit,
    required this.onDelete, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = student.payments.isNotEmpty &&
        student.payments.first.isPaid;
    final isExcluded = student.isExcludedThisMonth;

    return Dismissible(
      key: ValueKey(student.id),
      background: StudentSwipeBg(
        color: colors.colorPrimary,
        icon: Icons.edit_outlined,
        alignment: Alignment.centerLeft,
        label: 'Edit',
      ),
      secondaryBackground: StudentSwipeBg(
        color: colors.colorRedBox,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExcluded
                ? colors.colorGray.withOpacity(0.3)
                : isPaid
                    ? Colors.green.withOpacity(0.4)
                    : colors.colorDivider,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          color: isExcluded
                              ? colors.colorGray
                              : colors.colorPrimaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Grade: ${student.grade}',
                        style: TextStyle(
                            color: colors.colorSecondaryText,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${NumberFormatter.mmk
                        (student.monthlyFee)} / month',
                        style: TextStyle(
                          color: isExcluded
                              ? colors.colorGray
                              : colors.colorPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: colors.colorGray, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
