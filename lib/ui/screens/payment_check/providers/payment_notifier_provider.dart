import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/services/app_config_service.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/ensure_monthly_record_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/toggle_excluded_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/payment/toggle_payment_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/get_all_students_use_case.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_state.dart';

class PaymentNotifier extends AsyncNotifier<PaymentState> {
  @override
  Future<PaymentState> build() async {
    return _initialize();
  }

  // ── Init ────────────────────────────────────────────────────────────────

  Future<PaymentState> _initialize() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Ensure current month records exist
    await ref
        .read(ensureMonthlyRecordsUseCaseProvider)
        .execute(currentMonth);

    final firstUse = await AppConfigService.getOrSetFirstUseDate();
    final months = _buildMonthList(firstUse, currentMonth);

    final allStudents = await _getAllStudentsWithPayments();
    final currentMonthStudents =
        _filterStudentsForMonth(allStudents, now.year, now.month);
    final checkStudents =
        _filterStudentsForMonth(allStudents, now.year, now.month);
    final yearlyStats = _computeYearlyStats(allStudents, now.year);

    return PaymentState(
      currentMonthStudents: currentMonthStudents,
      checkStudents: checkStudents,
      availableMonths: months,
      selectedMonth: currentMonth,
      yearlyStats: yearlyStats,
    );
  }

  // ── Data loading helpers ─────────────────────────────────────────────────

  Future<List<StudentEntity>> _getAllStudentsWithPayments() async {
    return ref.read(getAllStudentUseCaseProvider).execute();
  }

  /// Returns students with only the payments for the given month.
  /// Excludes students who have isExcluded=true for that month.
  List<StudentEntity> _filterStudentsForMonth(
    List<StudentEntity> students,
    int year,
    int month,
  ) {
    final result = <StudentEntity>[];
    for (final student in students) {
      final monthPayment = student.payments.where((p) =>
          p.month.year == year &&
          p.month.month == month &&
          !p.isExcluded).toList();

      // Include student only if not excluded this month
      final excluded = student.payments.any((p) =>
          p.month.year == year &&
          p.month.month == month &&
          p.isExcluded);

      result.add(StudentEntity(
        id: student.id,
        name: student.name,
        grade: student.grade,
        monthlyFee: student.monthlyFee,
        // Include payment even if excluded so UI can show exclude state
        payments: student.payments
            .where((p) => p.month.year == year && p.month.month == month)
            .toList(),
        isExcludedThisMonth: excluded,
      ));
    }
    return result;
  }

  YearlyStats _computeYearlyStats(
      List<StudentEntity> students, int year) {
    double totalCollected = 0;
    double totalExpected = 0;
    int monthsWithData = 0;
    final monthsSet = <String>{};

    for (final student in students) {
      for (final payment in student.payments) {
        if (payment.month.year == year && !payment.isExcluded) {
          totalExpected += student.monthlyFee;
          if (payment.isPaid) totalCollected += payment.amountPaid;
          monthsSet.add('${payment.month.year}-${payment.month.month}');
        }
      }
    }

    monthsWithData = monthsSet.length;
    final monthlyAverage =
        monthsWithData > 0 ? totalCollected / monthsWithData : 0.0;
    final collectionRate =
        totalExpected > 0 ? totalCollected / totalExpected : 0.0;

    return YearlyStats(
      totalCollectedYear: totalCollected,
      totalExpectedYear: totalExpected,
      monthlyAverage: monthlyAverage,
      collectionRate: collectionRate,
    );
  }

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

  // ── Public actions ───────────────────────────────────────────────────────

  /// Toggle paid/unpaid. Refreshes both current-month and check-screen data.
  Future<void> togglePayment(
      int paymentId, bool isPaid, double monthlyFee) async {
    await ref
        .read(togglePaymentUseCaseProvider)
        .execute(paymentId, isPaid, monthlyFee);
    await _refreshAll();
  }

  /// Toggle excluded for a student in the selected check month.
  Future<void> toggleExcluded(int paymentId, bool isExcluded) async {
    await ref
        .read(toggleExcludedUseCaseProvider)
        .execute(paymentId, isExcluded);
    await _refreshAll();
  }

  /// Switch selected month in Payment Check screen.
  Future<void> selectMonth(DateTime month) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(isCheckLoading: true));

    final allStudents = await _getAllStudentsWithPayments();
    final checkStudents =
        _filterStudentsForMonth(allStudents, month.year, month.month);

    state = AsyncData(current.copyWith(
      checkStudents: checkStudents,
      selectedMonth: month,
      isCheckLoading: false,
    ));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _initialize());
  }

  Future<void> _refreshAll() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    final allStudents = await _getAllStudentsWithPayments();
    final currentMonthStudents =
        _filterStudentsForMonth(allStudents, now.year, now.month);
    final checkStudents = _filterStudentsForMonth(
      allStudents,
      current.selectedMonth.year,
      current.selectedMonth.month,
    );
    final yearlyStats = _computeYearlyStats(allStudents, now.year);

    state = AsyncData(current.copyWith(
      currentMonthStudents: currentMonthStudents,
      checkStudents: checkStudents,
      yearlyStats: yearlyStats,
    ));
  }
}

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, PaymentState>(() {
  return PaymentNotifier();
});