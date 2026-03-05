import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/widgets/student_card.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final studentsAsync = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Students List", style: TextStyle(color: colors.colorPrimaryText, fontWeight: FontWeight.bold)),
        backgroundColor: context.appColors.colorNavBarBg,
        elevation: 0,
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (students) {
          if (students.isEmpty) {
            return _buildEmptyState(colors);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = students[index];
              return StudentCard(student: student);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.colorButton,
        elevation: 0,
        onPressed: () => context.pushNamed(Routes.addStudents.name),
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
          Text("No students added yet", style: TextStyle(color: colors.colorPrimaryText, fontSize: 16)),
        ],
      ),
    );
  }
}