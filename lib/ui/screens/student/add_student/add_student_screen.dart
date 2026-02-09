import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';

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
    if (_formKey.currentState!.validate()) {
      final newStudent = StudentEntity(
        name: _nameController.text,
        grade: _gradeController.text,
        monthlyFee: double.parse(_feeController.text),
      );

      await ref.read(studentProvider.notifier).addStudent(newStudent);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLoading = ref.watch(studentProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.colorSecondary,
      appBar: AppBar(
        title: Text("Add New Student", style: TextStyle(color: colors.colorPrimaryText, fontWeight: FontWeight.bold)),
        backgroundColor: colors.colorWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.colorPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("Student Name", _nameController, colors),
              const SizedBox(height: 16),
              _buildField("Grade / Class", _gradeController, colors),
              const SizedBox(height: 16),
              _buildField("Monthly Fee Amount", _feeController, colors, isNumber: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.colorButton,
                    disabledBackgroundColor: colors.colorButtonDisable,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _save,
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Save Student", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, AppColors colors, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: colors.colorPrimaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.colorHint),
        filled: true,
        fillColor: colors.colorWhite,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.colorGray)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.colorPrimary, width: 2)),
      ),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }
}