import 'package:equatable/equatable.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';

class StudentEntity extends Equatable {
  final int? id;
  final String name;
  final String grade;
  final double monthlyFee;
  final List<PaymentRecordEntity> payments;

  /// True if this student is excluded for the currently viewed month.
  /// Only populated when loaded via PaymentNotifier.
  final bool isExcludedThisMonth;

  const StudentEntity({
    this.id,
    required this.name,
    required this.grade,
    required this.monthlyFee,
    this.payments = const [],
    this.isExcludedThisMonth = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    grade,
    monthlyFee,
    payments,
    isExcludedThisMonth,
  ];
}
