import 'package:equatable/equatable.dart';

class PaymentRecordEntity extends Equatable{
  final int id;

  final DateTime month;

  final bool isPaid;

  final double amountPaid;

  const PaymentRecordEntity({
    required this.id,
    required this.month,
    required this.isPaid,
    required this.amountPaid,
  });
  
  @override
  List<Object?> get props => [
    id,
    month,
    isPaid,
    amountPaid
  ];
}