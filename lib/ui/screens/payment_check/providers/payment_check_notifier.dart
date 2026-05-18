import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/services/app_config_service.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/ensure_monthly_record_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/toggle_payment_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/get_all_students_use_case.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_check_state.dart';

class PaymentCheckNotifier extends AsyncNotifier<PaymentCheckState> {
  @override
  Future<PaymentCheckState> build() async {
    return _initialize();
  }

  Future<PaymentCheckState> _initialize() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // 1. Get first-use date from shared_preferences
    final firstUse = await AppConfigService.getOrSetFirstUseDate();

    // 2. Build list of all months from firstUse to now (newest first)
    final months = _buildMonthList(firstUse, currentMonth);

    // 3. Ensure current month records exist for all students
    await ref
        .read(ensureMonthlyRecordsUseCaseProvider)
        .execute(currentMonth);

    // 4. Load students for current month
    final students = await _loadStudentsForMonth(currentMonth);

    return PaymentCheckState(
      students: students,
      availableMonths: months,
      selectedMonth: currentMonth,
    );
  }

  /// Generates months from [first] to [current], newest first.
  List<DateTime> _buildMonthList(DateTime first, DateTime current) {
    final months = <DateTime>[];
    var cursor = DateTime(current.year, current.month, 1);
    final stop = DateTime(first.year, first.month, 1);

    while (!cursor.isBefore(stop)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    return months;
  }

  Future<List<StudentEntity>> _loadStudentsForMonth(DateTime month) async {
    // Load all students with full payment history
    final students = await ref.read(getAllStudentUseCaseProvider).execute();

    // Filter each student's payments to only the selected month
    return students.map((student) {
      final monthPayments = student.payments
          .where((p) =>
              p.month.year == month.year && p.month.month == month.month)
          .toList();
      return StudentEntity(
        id: student.id,
        name: student.name,
        grade: student.grade,
        monthlyFee: student.monthlyFee,
        payments: monthPayments,
      );
    }).toList();
  }

  /// Called when user picks a different month from the dropdown.
  Future<void> selectMonth(DateTime month) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final students = await _loadStudentsForMonth(month);

    state = AsyncData(current.copyWith(
      students: students,
      selectedMonth: month,
      isLoading: false,
    ));
  }

  /// Toggle paid/unpaid for a student in the selected month.
  Future<void> togglePayment(
      int paymentId, bool isPaid, double monthlyFee) async {
    await ref
        .read(togglePaymentUseCaseProvider)
        .execute(paymentId, isPaid, monthlyFee);

    final current = state.valueOrNull;
    if (current == null) return;

    final students = await _loadStudentsForMonth(current.selectedMonth);
    state = AsyncData(current.copyWith(students: students));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _initialize());
  }
}

final paymentCheckProvider =
    AsyncNotifierProvider<PaymentCheckNotifier, PaymentCheckState>(() {
  return PaymentCheckNotifier();
});