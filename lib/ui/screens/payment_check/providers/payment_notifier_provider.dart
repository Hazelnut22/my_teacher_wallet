import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/ensure_monthly_record_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/toggle_payment_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/get_all_students_use_case.dart';

/// Current-month payment state. Used by Home screen and Students screen.
class PaymentNotifier extends AsyncNotifier<List<StudentEntity>> {
  @override
  Future<List<StudentEntity>> build() async {
    return _buildStudentList();
  }

  Future<List<StudentEntity>> _buildStudentList() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // 1. Ensure every student has a record for this month
    await ref
        .read(ensureMonthlyRecordsUseCaseProvider)
        .execute(monthStart);

    // 2. Load all students — getAllStudents loads full payment history per student
    final students = await ref.read(getAllStudentUseCaseProvider).execute();

    // 3. Attach only the current-month payment to each student entity
    return _filterToCurrentMonth(students, now);
  }

  List<StudentEntity> _filterToCurrentMonth(
    List<StudentEntity> students,
    DateTime now,
  ) {
    return students.map((student) {
      final currentPayment = student.payments
          .where((p) =>
              p.month.year == now.year && p.month.month == now.month)
          .toList();

      return StudentEntity(
        id: student.id,
        name: student.name,
        grade: student.grade,
        monthlyFee: student.monthlyFee,
        payments: currentPayment,
      );
    }).toList();
  }

  Future<void> togglePayment(
      int paymentId, bool isPaid, double monthlyFee) async {
    await ref
        .read(togglePaymentUseCaseProvider)
        .execute(paymentId, isPaid, monthlyFee);
    state = AsyncData(await _buildStudentList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _buildStudentList());
  }
}

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, List<StudentEntity>>(() {
  return PaymentNotifier();
});
