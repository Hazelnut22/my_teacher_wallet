import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

class PaymentCheckState {
  final List<StudentEntity> students;
  final List<DateTime> availableMonths; // descending: newest first
  final DateTime selectedMonth;
  final bool isLoading;

  const PaymentCheckState({
    required this.students,
    required this.availableMonths,
    required this.selectedMonth,
    this.isLoading = false,
  });

  PaymentCheckState copyWith({
    List<StudentEntity>? students,
    List<DateTime>? availableMonths,
    DateTime? selectedMonth,
    bool? isLoading,
  }) {
    return PaymentCheckState(
      students: students ?? this.students,
      availableMonths: availableMonths ?? this.availableMonths,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}