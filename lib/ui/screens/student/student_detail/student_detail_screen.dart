import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentEntity student;

  const StudentDetailScreen({super.key, required this.student});

  // Helper to format date: "March 2026"
  String _formatMonth(DateTime date) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.colorSecondary,
      appBar: AppBar(
        title: const Text("Student Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colors.colorWhite,
        foregroundColor: colors.colorPrimaryText,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.colorWhite,
              border: Border(bottom: BorderSide(color: colors.colorDivider)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.colorSecondary, // Using our light blue secondary
                  child: Text(student.name[0].toUpperCase(), 
                    style: TextStyle(color: colors.colorPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.colorPrimaryText)),
                      Text("Grade: ${student.grade}", style: TextStyle(color: colors.colorPrimaryText)),
                    ],
                  ),
                ),
                Text("${student.monthlyFee}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.colorPrimary)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text("Payment History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.colorPrimaryText)),
              ],
            ),
          ),

          Expanded(
            child: student.payments.isEmpty 
              ? Center(child: Text("No payment records found", style: TextStyle(color: colors.colorHint)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: student.payments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final payment = student.payments[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: colors.colorWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.colorDivider),
                      ),
                      child: ListTile(
                        leading: Icon(
                          payment.isPaid ? Icons.check_circle : Icons.pending_actions,
                          color: payment.isPaid ? Colors.green : colors.colorRedBox,
                        ),
                        title: Text(_formatMonth(payment.month), style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(payment.isPaid ? "Received" : "Outstanding"),
                        trailing: Text(
                          payment.isPaid ? "Paid" : "Pending", 
                          style: TextStyle(
                            color: payment.isPaid ? Colors.green : colors.colorRedBox, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}