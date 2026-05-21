import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

/// Yearly stats shown above the month dropdown in Payment Check.
class YearlyStats {
  final double totalCollectedYear;
  final double totalExpectedYear;
  final double monthlyAverage;
  final double collectionRate;

  const YearlyStats({
    required this.totalCollectedYear,
    required this.totalExpectedYear,
    required this.monthlyAverage,
    required this.collectionRate,
  });
}

/// Monthly breakdown entry used in the report.
class MonthlyReportEntry {
  final DateTime month;
  final double collected;
  final double expected;
  final int paidCount;
  final int unpaidCount;
  final int excludedCount;

  const MonthlyReportEntry({
    required this.month,
    required this.collected,
    required this.expected,
    required this.paidCount,
    required this.unpaidCount,
    required this.excludedCount,
  });

  double get collectionRate => expected == 0 ? 0 : collected / expected;
}

/// Per-student summary used in the report.
class StudentReportEntry {
  final String name;
  final String grade;
  final double monthlyFee;
  final int monthsPaid;
  final int monthsUnpaid;
  final int monthsExcluded;
  final double totalPaid;

  const StudentReportEntry({
    required this.name,
    required this.grade,
    required this.monthlyFee,
    required this.monthsPaid,
    required this.monthsUnpaid,
    required this.monthsExcluded,
    required this.totalPaid,
  });

  int get totalActive => monthsPaid + monthsUnpaid;
  double get attendanceRate =>
      totalActive == 0 ? 0 : monthsPaid / totalActive;
}

/// Full report data for the current year.
class ReportData {
  final int year;
  final int totalStudents;
  final double totalCollected;
  final double totalExpected;
  final double collectionRate;
  final List<MonthlyReportEntry> monthlyBreakdown;
  final List<StudentReportEntry> studentBreakdown;
  final MonthlyReportEntry? bestMonth;
  final MonthlyReportEntry? worstMonth;
  final StudentReportEntry? mostConsistentStudent;

  const ReportData({
    required this.year,
    required this.totalStudents,
    required this.totalCollected,
    required this.totalExpected,
    required this.collectionRate,
    required this.monthlyBreakdown,
    required this.studentBreakdown,
    this.bestMonth,
    this.worstMonth,
    this.mostConsistentStudent,
  });
}

/// The single unified payment state used across all screens.
class PaymentState {
  final List<StudentEntity> currentMonthStudents;
  final List<StudentEntity> checkStudents;
  final List<DateTime> availableMonths;
  final DateTime selectedMonth;
  final bool isCheckLoading;
  final YearlyStats yearlyStats;
  final ReportData reportData;

  const PaymentState({
    required this.currentMonthStudents,
    required this.checkStudents,
    required this.availableMonths,
    required this.selectedMonth,
    required this.yearlyStats,
    required this.reportData,
    this.isCheckLoading = false,
  });

  PaymentState copyWith({
    List<StudentEntity>? currentMonthStudents,
    List<StudentEntity>? checkStudents,
    List<DateTime>? availableMonths,
    DateTime? selectedMonth,
    YearlyStats? yearlyStats,
    ReportData? reportData,
    bool? isCheckLoading,
  }) {
    return PaymentState(
      currentMonthStudents:
          currentMonthStudents ?? this.currentMonthStudents,
      checkStudents: checkStudents ?? this.checkStudents,
      availableMonths: availableMonths ?? this.availableMonths,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      yearlyStats: yearlyStats ?? this.yearlyStats,
      reportData: reportData ?? this.reportData,
      isCheckLoading: isCheckLoading ?? this.isCheckLoading,
    );
  }
}