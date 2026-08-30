import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/core/services/shared_preference_service.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/widgets/swipable_student_card.dart';
import 'package:my_teacher_wallet/ui/widgets/error_state_view.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showSwipeHint = false;

  @override
  void initState() {
    super.initState();
    _checkSwipeHint();
  }

  Future<void> _checkSwipeHint() async {
    final seen = await SharedPreferenceService.hasSeenSwipeHint();
    if (!seen && mounted) {
      setState(() => _showSwipeHint = true);
    }
  }

  Future<void> _dismissSwipeHint() async {
    await SharedPreferenceService.markSwipeHintSeen();
    if (mounted) setState(() => _showSwipeHint = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentEntity> _filtered(List<StudentEntity> students) {
    if (_query.isEmpty) return students;
    final q = _query.toLowerCase();
    return students
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.grade.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Student'),
            content: Text(
              'Remove $name? All payment records will also be deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stateAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Students',
          style: context.appFonts.appBarTitle()?.copyWith(
            color: colors.colorPrimaryText,
          ),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Swipe hint banner ──────────────────────────────────────────
          if (_showSwipeHint)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.colorPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.colorPrimary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.swipe, color: colors.colorPrimary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Swipe right to edit  •  Swipe left to delete',
                      style: context.appFonts.bodyMedium()?.copyWith(
                        color: colors.colorPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismissSwipeHint,
                    child: Icon(
                      Icons.close,
                      color: colors.colorPrimary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: context.appFonts.headlineLarge()?.copyWith(
                color: colors.colorPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or grade...',
                hintStyle: context.appFonts.headlineLarge()?.copyWith(
                color: colors.colorHint,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
                prefixIcon: Icon(Icons.search, color: colors.colorHint),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.colorHint),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.colorWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.colorDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.colorPrimary, width: 2),
                ),
              ),
            ),
          ),

          // ── Student count + list ───────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(paymentProvider)),
              data: (paymentState) {
                final allStudents = paymentState.currentMonthStudents;
                final students = _filtered(allStudents);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            _query.isNotEmpty
                                ? '${students.length} of ${allStudents.length} students'
                                : '${allStudents.length} student${allStudents.length == 1 ? '' : 's'}',
                            style: context.appFonts.bodyMedium()?.copyWith(
                              color: colors.colorSecondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: students.isEmpty
                          ? _buildEmptyState(colors)
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: students.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final student = students[index];
                                return SwipableStudentCard(
                                  student: student,
                                  onTap: () => context.pushNamed(
                                    Routes.studentDetail.name,
                                    extra: student,
                                  ),
                                  onEdit: () async {
                                    final updatedStudent =
                                        await context.pushNamed<StudentEntity?>(
                                      Routes.editStudent.name,
                                      extra: student,
                                    );

                                    if (updatedStudent != null) {
                                      ref.read(paymentProvider.notifier).refresh();
                                    }
                                  },
                                  onDelete: () async {
                                    final confirm = await _confirmDelete(
                                      context,
                                      student.name,
                                    );
                                    if (confirm && student.id != null) {
                                      await ref
                                          .read(studentProvider.notifier)
                                          .removeStudent(student.id!);
                                      ref
                                          .read(paymentProvider.notifier)
                                          .refresh();
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.colorButton,
        elevation: 0,
        onPressed: () async {
          await context.pushNamed(Routes.addStudents.name);
          ref.read(paymentProvider.notifier).refresh();
        },
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.userGraduate,
            size: 64,
            color: colors.colorHint,
          ),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'No students match "$_query"'
                : 'No students added',
            style:  context.appFonts.bodyLarge()?.copyWith(color: colors.colorPrimaryText),
          ),
          if (_query.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first student',
              style: context.appFonts.bodyMedium()?.copyWith(color: colors.colorHint, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
