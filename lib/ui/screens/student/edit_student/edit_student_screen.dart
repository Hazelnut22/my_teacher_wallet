import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';
import 'package:my_teacher_wallet/ui/widgets/custom_input_text_field.dart';

class EditStudentScreen extends ConsumerStatefulWidget {
  final StudentEntity student;

  const EditStudentScreen({super.key, required this.student});

  @override
  ConsumerState<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _gradeController = TextEditingController(text: widget.student.grade);
    _feeController = TextEditingController(
        text: widget.student.monthlyFee.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = StudentEntity(
      id: widget.student.id,
      name: _nameController.text.trim(),
      grade: _gradeController.text.trim(),
      monthlyFee: double.parse(_feeController.text.trim()),
      payments: widget.student.payments,
    );

    await ref.read(studentProvider.notifier).updateStudent(updated);

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Student"),
        content: Text(
            "Are you sure you want to delete ${widget.student.name}? This will also remove all payment records."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.student.id != null) {
      await ref.read(studentProvider.notifier).removeStudent(widget.student.id!);
      if (mounted) {
        // Pop detail screen and edit screen
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLoading = ref.watch(studentProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          "Edit Student",
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: isLoading ? null : _delete,
            tooltip: "Delete student",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar preview
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.colorSecondary,
                  child: Text(
                    widget.student.name[0].toUpperCase(),
                    style: TextStyle(
                        color: colors.colorPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              CustomInputTextField(label: "Student Name", controller:  _nameController),
              const SizedBox(height: 16),
              CustomInputTextField(label: "Grade / Class", controller:  _gradeController),
              const SizedBox(height: 16),
              CustomInputTextField(label: "Monthly Fee (MMK)", controller:  _feeController, isNumber: true),
              const SizedBox(height: 36),

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
                          "Save Changes",
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