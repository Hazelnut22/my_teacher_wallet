import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

/// Yearly stats calculated from all payment records in the current year.
class YearlyStats {
  final double totalCollectedYear;
  final double totalExpectedYear;
  final double monthlyAverage;
  final double collectionRate; // 0.0 - 1.0

  const YearlyStats({
    required this.totalCollectedYear,
    required this.totalExpectedYear,
    required this.monthlyAverage,
    required this.collectionRate,
  });
}

/// The single unified payment state used across all screens.
class PaymentState {
  // ── Current month (Home + Students screens) ─────────────────────────────
  final List<StudentEntity> currentMonthStudents;

  // ── Payment check screen ─────────────────────────────────────────────────
  final List<StudentEntity> checkStudents;
  final List<DateTime> availableMonths;
  final DateTime selectedMonth;
  final bool isCheckLoading;

  // ── Yearly stats (Payment check screen) ─────────────────────────────────
  final YearlyStats yearlyStats;

  const PaymentState({
    required this.currentMonthStudents,
    required this.checkStudents,
    required this.availableMonths,
    required this.selectedMonth,
    required this.yearlyStats,
    this.isCheckLoading = false,
  });

  PaymentState copyWith({
    List<StudentEntity>? currentMonthStudents,
    List<StudentEntity>? checkStudents,
    List<DateTime>? availableMonths,
    DateTime? selectedMonth,
    YearlyStats? yearlyStats,
    bool? isCheckLoading,
  }) {
    return PaymentState(
      currentMonthStudents:
          currentMonthStudents ?? this.currentMonthStudents,
      checkStudents: checkStudents ?? this.checkStudents,
      availableMonths: availableMonths ?? this.availableMonths,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      yearlyStats: yearlyStats ?? this.yearlyStats,
      isCheckLoading: isCheckLoading ?? this.isCheckLoading,
    );
  }
}