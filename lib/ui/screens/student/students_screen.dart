import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/widgets/student_card.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final studentsAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          "Students",
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (students) {
          if (students.isEmpty) return _buildEmptyState(colors);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return StudentCard(student: students[index], isChecklist: false,);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.colorButton,
        elevation: 0,
        onPressed: () async {
          await context.pushNamed(Routes.addStudents.name);
          // Refresh after adding a student so new month record is created
          ref.read(paymentProvider.notifier).refresh();
        },
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.userGraduate, size: 64, color: colors.colorHint),
          const SizedBox(height: 16),
          Text(
            "No students added yet",
            style: TextStyle(color: colors.colorPrimaryText, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add your first student",
            style: TextStyle(color: colors.colorHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}