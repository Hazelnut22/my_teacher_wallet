import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

final studentHistoryProvider =
    FutureProvider.family<List<PaymentRecordEntity>, int>((
      ref,
      studentId,
    ) async {
      final isar = ref.watch(dbProvider);
      final student = await isar.students.get(studentId);
      if (student == null) return [];
      await student.paymentRecords.load();
      final sorted = student.paymentRecords.toList()
        ..sort((a, b) => b.month.compareTo(a.month));
      return sorted.map((p) => p.toEntity()).toList();
    });

class StudentDetailScreen extends ConsumerStatefulWidget {
  final StudentEntity student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  late StudentEntity _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  String _formatMonth(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fonts = context.appFonts;
    final historyAsync = ref.watch(studentHistoryProvider(_student.id ?? 0));

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          _student.name,
          style: fonts.appBarTitle()?.copyWith(color: colors.colorPrimaryText),
        ),
        backgroundColor: colors.colorNavBarBg,
        foregroundColor: colors.colorPrimaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.colorPrimary),
            onPressed: () async {
              final updatedStudent =
                  await context.pushNamed<StudentEntity?>(
                Routes.editStudent.name,
                extra: _student,
              );

              if (updatedStudent != null) {
                setState(() {
                  _student = updatedStudent;
                });

                ref.read(paymentProvider.notifier).refresh();
                ref.invalidate(studentHistoryProvider(_student.id ?? 0));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.colorDivider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.colorSecondary,
                  child: Text(
                    _student.name[0].toUpperCase(),
                    style: fonts.headlineMedium()?.copyWith(
                      color: colors.colorPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _student.name,
                        style: fonts.headlineSmall()?.copyWith(
                          color: colors.colorPrimaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Grade: ${_student.grade}",
                        style: fonts.bodySmall()?.copyWith(
                          color: colors.colorSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _student.monthlyFee.toStringAsFixed(0),
                      style: fonts.headlineSmall()?.copyWith(
                        color: colors.colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "MMK / month",
                      style: fonts.bodySmall()?.copyWith(
                        color: colors.colorSecondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text(
                  "Payment History",
                  style: fonts.headlineSmall()?.copyWith(
                    color: colors.colorPrimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (payments) {
                if (payments.isEmpty) {
                  return Center(
                    child: Text(
                      "No payment records yet",
                      style: fonts.bodyMedium()?.copyWith(
                        color: colors.colorHint,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    final isCurrentMonth =
                        payment.month.year == DateTime.now().year &&
                        payment.month.month == DateTime.now().month;

                    Color statusColor;
                    IconData statusIcon;
                    String statusLabel;

                    if (payment.isExcluded) {
                      statusColor = colors.colorGray;
                      statusIcon = Icons.remove_circle_outline;
                      statusLabel = 'Excluded';
                    } else if (payment.isPaid) {
                      statusColor = colors.colorSuccess;
                      statusIcon = Icons.check_circle_rounded;
                      statusLabel = 'Paid';
                    } else {
                      statusColor = colors.colorRedBox;
                      statusIcon = Icons.radio_button_unchecked;
                      statusLabel = 'Unpaid';
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: colors.colorWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: payment.isPaid
                              ? colors.colorSuccess.withOpacity(0.3)
                              : colors.colorDivider,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Row(
                          children: [
                            Text(
                              _formatMonth(payment.month),
                              style: fonts.titleLarge()?.copyWith(
                                color: colors.colorPrimaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.colorPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "This month",
                                  style: fonts.bodySmall()?.copyWith(
                                    color: colors.colorPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          payment.isPaid
                              ? "${payment.amountPaid.toStringAsFixed(0)} MMK received"
                              : "Pending",
                          style: fonts.bodySmall()?.copyWith(
                            color: statusColor,
                          ),
                        ),
                        trailing: Text(
                          payment.isPaid ? "Paid" : "Unpaid",
                          style: fonts.bodySmall()?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
