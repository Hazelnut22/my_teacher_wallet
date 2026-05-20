import 'package:equatable/equatable.dart';

class PaymentRecordEntity extends Equatable {
  final int id;
  final DateTime month;
  final bool isPaid;
  final double amountPaid;
  final bool isExcluded;
 
  const PaymentRecordEntity({
    required this.id,
    required this.month,
    required this.isPaid,
    required this.amountPaid,
    this.isExcluded = false,
  });
 
  @override
  List<Object?> get props => [id, month, isPaid, amountPaid, isExcluded];
}