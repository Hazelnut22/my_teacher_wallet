import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/settings/widgets/faq_tile.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const faqs = [
      FaqModel(
        question: 'How do I add a student?',
        answer:
            'Go to the Students tab and tap the + button. Enter the student\'s name, grade, and monthly fee, then tap Save.',
      ),
      FaqModel(
        question: 'How do I mark a student as paid?',
        answer:
            'Open the Payment Check tab, find the student for the current month, and toggle the switch on the right to mark them as paid.',
      ),
      FaqModel(
        question: 'What does "Exclude" mean?',
        answer:
            'Excluding a student for a month means they took a break or are not attending that month. They won\'t appear in the payment total and their record will show as excluded.',
      ),
      FaqModel(
        question: 'How do I exclude a student for a month?',
        answer:
            'In the Payment Check screen, tap the ⋮ icon on a student\'s card and choose "Exclude this student this month". You can include them again the same way.',
      ),
      FaqModel(
        question: 'Can I edit or delete a student?',
        answer:
            'Yes. In the Students tab, swipe right on a student card to edit, or swipe left to delete. You can also tap a card to open their detail page and edit from there.',
      ),
      FaqModel(
        question: 'How does the monthly reset work?',
        answer:
            'Each month, all student payments are automatically reset to unpaid. Previous months\' records are preserved and viewable in the Payment Check screen by selecting a past month from the dropdown.',
      ),
      FaqModel(
        question: 'What is the Yearly Report?',
        answer:
            'The Yearly Report (in the Payment Check tab) shows a full summary of the current year: total collected, monthly trends, best and worst months, and a per-student breakdown.',
      ),
      FaqModel(
        question: 'How do I reset all data?',
        answer:
            'Go to Settings and tap "Reset All Data". This will permanently delete all students and payment records and cannot be undone.',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text('Help & Info',
            style: TextStyle(
                color: colors.colorPrimaryText,
                fontWeight: FontWeight.bold)),
        backgroundColor: colors.colorNavBarBg,
        foregroundColor: colors.colorPrimaryText,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return FaqTile(faq: faqs[index]);
        },
      ),
    );
  }
}

class FaqModel {
  final String question;
  final String answer;
  const FaqModel({required this.question, required this.answer});
}