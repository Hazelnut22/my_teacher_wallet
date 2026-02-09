import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.colorGray),
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
          context.pushNamed(
            Routes.studentDetail.name, 
            extra: student,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Initial Circle
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.colorPrimary,
                child: Text(
                  student.name[0].toUpperCase(),
                  style: TextStyle(color: colors.colorPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Grade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        color: colors.colorPrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Grade: ${student.grade}",
                      style: TextStyle(color: colors.colorPrimaryText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Fee Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${student.monthlyFee}",
                    style: TextStyle(
                      color: colors.colorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}