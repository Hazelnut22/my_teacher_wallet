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

    await ref
        .read(ensureMonthlyRecordsUseCaseProvider)
        .execute(currentMonth);

    final firstUse = await AppConfigService.getOrSetFirstUseDate();
    final months = _buildMonthList(firstUse, currentMonth);
    final allStudents = await _getAllStudents();

    final currentMonthStudents =
        _sortedForHome(_buildStudentsForMonth(allStudents, now.year, now.month));
    final checkStudents =
        _sortedForCheck(_buildStudentsForMonth(allStudents, now.year, now.month));

    final yearlyStats = _computeYearlyStats(allStudents, now.year);
    final reportData = _computeReportData(allStudents, now.year);

    return PaymentState(
      currentMonthStudents: currentMonthStudents,
      checkStudents: checkStudents,
      availableMonths: months,
      selectedMonth: currentMonth,
      yearlyStats: yearlyStats,
      reportData: reportData,
    );
  }

  // ── Data helpers ─────────────────────────────────────────────────────────

  Future<List<StudentEntity>> _getAllStudents() {
    return ref.read(getAllStudentUseCaseProvider).execute();
  }

  /// Builds a student list for a given month, attaching only that month's payment.
  List<StudentEntity> _buildStudentsForMonth(
    List<StudentEntity> students,
    int year,
    int month,
  ) {
    return students.map((student) {
      final monthPayments = student.payments
          .where((p) => p.month.year == year && p.month.month == month)
          .toList();
      final isExcluded =
          monthPayments.isNotEmpty && monthPayments.first.isExcluded;

      return StudentEntity(
        id: student.id,
        name: student.name,
        grade: student.grade,
        monthlyFee: student.monthlyFee,
        payments: monthPayments,
        isExcludedThisMonth: isExcluded,
      );
    }).toList();
  }

  /// Home sort: Paid → Excluded
  List<StudentEntity> _sortedForHome(List<StudentEntity> students) {
    final paid = students.where((s) =>
        !s.isExcludedThisMonth &&
        s.payments.isNotEmpty &&
        s.payments.first.isPaid).toList();
    final excluded = students.where((s) => s.isExcludedThisMonth).toList();
    // Pending students shown separately in home; all go in this list sorted
    final unpaid = students.where((s) =>
        !s.isExcludedThisMonth &&
        (s.payments.isEmpty || !s.payments.first.isPaid)).toList();
    return [...paid, ...unpaid, ...excluded];
  }

  /// Payment Check sort: Unpaid → Paid → Excluded
  List<StudentEntity> _sortedForCheck(List<StudentEntity> students) {
    final unpaid = students.where((s) =>
        !s.isExcludedThisMonth &&
        (s.payments.isEmpty || !s.payments.first.isPaid)).toList();
    final paid = students.where((s) =>
        !s.isExcludedThisMonth &&
        s.payments.isNotEmpty &&
        s.payments.first.isPaid).toList();
    final excluded = students.where((s) => s.isExcludedThisMonth).toList();
    return [...unpaid, ...paid, ...excluded];
  }

  // ── Stats ────────────────────────────────────────────────────────────────

  YearlyStats _computeYearlyStats(List<StudentEntity> students, int year) {
    double totalCollected = 0;
    double totalExpected = 0;
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

    final monthsWithData = monthsSet.length;
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

  ReportData _computeReportData(List<StudentEntity> students, int year) {
    // Build monthly breakdown for all 12 months
    final monthlyBreakdown = <MonthlyReportEntry>[];
    for (int m = 1; m <= 12; m++) {
      double collected = 0;
      double expected = 0;
      int paidCount = 0;
      int unpaidCount = 0;
      int excludedCount = 0;

      for (final student in students) {
        final payment = student.payments.where((p) =>
            p.month.year == year && p.month.month == m).toList();
        if (payment.isEmpty) continue;
        final p = payment.first;
        if (p.isExcluded) {
          excludedCount++;
        } else {
          expected += student.monthlyFee;
          if (p.isPaid) {
            collected += p.amountPaid;
            paidCount++;
          } else {
            unpaidCount++;
          }
        }
      }

      // Only include months that have any data
      if (expected > 0 || excludedCount > 0) {
        monthlyBreakdown.add(MonthlyReportEntry(
          month: DateTime(year, m, 1),
          collected: collected,
          expected: expected,
          paidCount: paidCount,
          unpaidCount: unpaidCount,
          excludedCount: excludedCount,
        ));
      }
    }

    // Per-student breakdown
    final studentBreakdown = students.map((student) {
      final yearPayments =
          student.payments.where((p) => p.month.year == year).toList();
      final monthsPaid =
          yearPayments.where((p) => p.isPaid && !p.isExcluded).length;
      final monthsExcluded = yearPayments.where((p) => p.isExcluded).length;
      final monthsUnpaid = yearPayments
          .where((p) => !p.isPaid && !p.isExcluded)
          .length;
      final totalPaid = yearPayments
          .where((p) => p.isPaid)
          .fold<double>(0, (s, p) => s + p.amountPaid);

      return StudentReportEntry(
        name: student.name,
        grade: student.grade,
        monthlyFee: student.monthlyFee,
        monthsPaid: monthsPaid,
        monthsUnpaid: monthsUnpaid,
        monthsExcluded: monthsExcluded,
        totalPaid: totalPaid,
      );
    }).toList();

    // Highlights
    final sortedMonths = [...monthlyBreakdown]
      ..sort((a, b) => b.collectionRate.compareTo(a.collectionRate));
    final bestMonth =
        sortedMonths.isNotEmpty ? sortedMonths.first : null;
    final worstMonth =
        sortedMonths.isNotEmpty ? sortedMonths.last : null;

    final sortedStudents = [...studentBreakdown]
      ..sort((a, b) => b.attendanceRate.compareTo(a.attendanceRate));
    final mostConsistent =
        sortedStudents.isNotEmpty ? sortedStudents.first : null;

    final totalCollected = monthlyBreakdown.fold<double>(
        0, (s, m) => s + m.collected);
    final totalExpected = monthlyBreakdown.fold<double>(
        0, (s, m) => s + m.expected);

    return ReportData(
      year: year,
      totalStudents: students.length,
      totalCollected: totalCollected,
      totalExpected: totalExpected,
      collectionRate:
          totalExpected > 0 ? totalCollected / totalExpected : 0,
      monthlyBreakdown: monthlyBreakdown,
      studentBreakdown: studentBreakdown,
      bestMonth: bestMonth,
      worstMonth: worstMonth,
      mostConsistentStudent: mostConsistent,
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

  // ── Public actions ────────────────────────────────────────────────────────

  Future<void> togglePayment(
      int paymentId, bool isPaid, double monthlyFee) async {
    await ref
        .read(togglePaymentUseCaseProvider)
        .execute(paymentId, isPaid, monthlyFee);
    await _refreshAll();
  }

  Future<void> toggleExcluded(int paymentId, bool isExcluded) async {
    await ref
        .read(toggleExcludedUseCaseProvider)
        .execute(paymentId, isExcluded);
    await _refreshAll();
  }

  Future<void> selectMonth(DateTime month) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isCheckLoading: true));
    final allStudents = await _getAllStudents();
    final checkStudents = _sortedForCheck(
        _buildStudentsForMonth(allStudents, month.year, month.month));
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
    final allStudents = await _getAllStudents();

    state = AsyncData(current.copyWith(
      currentMonthStudents:
          _sortedForHome(_buildStudentsForMonth(allStudents, now.year, now.month)),
      checkStudents: _sortedForCheck(_buildStudentsForMonth(
        allStudents,
        current.selectedMonth.year,
        current.selectedMonth.month,
      )),
      yearlyStats: _computeYearlyStats(allStudents, now.year),
      reportData: _computeReportData(allStudents, now.year),
    ));
  }
}

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, PaymentState>(() {
  return PaymentNotifier();
});