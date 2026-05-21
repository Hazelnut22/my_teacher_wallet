import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const faqs = [
      _FAQ(
        question: 'How do I add a student?',
        answer:
            'Go to the Students tab and tap the + button. Enter the student\'s name, grade, and monthly fee, then tap Save.',
      ),
      _FAQ(
        question: 'How do I mark a student as paid?',
        answer:
            'Open the Payment Check tab, find the student for the current month, and toggle the switch on the right to mark them as paid.',
      ),
      _FAQ(
        question: 'What does "Exclude" mean?',
        answer:
            'Excluding a student for a month means they took a break or are not attending that month. They won\'t appear in the payment total and their record will show as excluded.',
      ),
      _FAQ(
        question: 'How do I exclude a student for a month?',
        answer:
            'In the Payment Check screen, tap the ⋮ icon on a student\'s card and choose "Exclude this student this month". You can include them again the same way.',
      ),
      _FAQ(
        question: 'Can I edit or delete a student?',
        answer:
            'Yes. In the Students tab, swipe right on a student card to edit, or swipe left to delete. You can also tap a card to open their detail page and edit from there.',
      ),
      _FAQ(
        question: 'How does the monthly reset work?',
        answer:
            'Each month, all student payments are automatically reset to unpaid. Previous months\' records are preserved and viewable in the Payment Check screen by selecting a past month from the dropdown.',
      ),
      _FAQ(
        question: 'What is the Yearly Report?',
        answer:
            'The Yearly Report (in the Payment Check tab) shows a full summary of the current year: total collected, monthly trends, best and worst months, and a per-student breakdown.',
      ),
      _FAQ(
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
          return _FAQTile(faq: faqs[index], colors: colors);
        },
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  final AppColors colors;
  const _FAQTile({required this.faq, required this.colors});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.colorDivider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 14),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          trailing: Icon(
            _expanded ? Icons.remove : Icons.add,
            color: colors.colorPrimary,
            size: 18,
          ),
          title: Text(
            widget.faq.question,
            style: TextStyle(
              color: colors.colorPrimaryText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          children: [
            Text(
              widget.faq.answer,
              style: TextStyle(
                color: colors.colorSecondaryText,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}