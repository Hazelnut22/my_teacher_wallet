import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';
import 'package:my_teacher_wallet/ui/widgets/custom_input_text_field.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _feeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newStudent = StudentEntity(
      name: _nameController.text.trim(),
      grade: _gradeController.text.trim(),
      monthlyFee: double.parse(_feeController.text.trim()),
    );

    await ref.read(studentProvider.notifier).addStudent(newStudent);
    // Refresh payment provider so new student gets a current-month record
    await ref.read(paymentProvider.notifier).refresh();

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLoading = ref.watch(studentProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          "Add New Student",
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.colorPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputTextField(label: "Student Name", controller: _nameController),
              const SizedBox(height: 16),
              CustomInputTextField(label: "Grade / Class", controller: _gradeController),
              const SizedBox(height: 16),
              CustomInputTextField(label: "Monthly Fee (MMK)", controller: _feeController, isNumber: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.colorButton,
                    disabledBackgroundColor: colors.colorButtonDisable,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          "Save Student",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
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