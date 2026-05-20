import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentEntity> _filtered(List<StudentEntity> students) {
    if (_query.isEmpty) return students;
    final q = _query.toLowerCase();
    return students
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.grade.toLowerCase().contains(q))
        .toList();
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Student'),
            content: Text(
                'Remove $name? All payment records will also be deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, ) {
    final colors = context.appColors;
    final stateAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Students',
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: colors.colorPrimaryText),
              decoration: InputDecoration(
                hintText: 'Search by name or grade...',
                hintStyle: TextStyle(color: colors.colorHint),
                prefixIcon:
                    Icon(Icons.search, color: colors.colorHint),
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
                  borderSide:
                      BorderSide(color: colors.colorPrimary, width: 2),
                ),
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (paymentState) {
                final students =
                    _filtered(paymentState.currentMonthStudents);

                if (students.isEmpty) {
                  return _buildEmptyState(colors);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: students.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _SwipeStudentCard(
                      student: student,
                      onEdit: () => context.pushNamed(
                        Routes.studentDetail.name,
                        extra: student,
                      ),
                      onDelete: () async {
                        final confirm = await _confirmDelete(
                            context, student.name);
                        if (confirm && student.id != null) {
                          await ref
                              .read(studentProvider.notifier)
                              .removeStudent(student.id!);
                          ref.read(paymentProvider.notifier).refresh();
                        }
                      },
                    );
                  },
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
          Icon(FontAwesomeIcons.userGraduate,
              size: 64, color: colors.colorHint),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'No students match "$_query"'
                : 'No students added yet',
            style:
                TextStyle(color: colors.colorPrimaryText, fontSize: 16),
          ),
          if (_query.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first student',
              style: TextStyle(color: colors.colorHint, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Swipeable student card ─────────────────────────────────────────────────────

class _SwipeStudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SwipeStudentCard({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = student.payments.isNotEmpty &&
        student.payments.first.isPaid;
    final isExcluded = student.isExcludedThisMonth;

    return Dismissible(
      key: ValueKey(student.id),
      // Swipe right → edit (blue background)
      background: _SwipeBg(
        color: colors.colorPrimary,
        icon: Icons.edit_outlined,
        alignment: Alignment.centerLeft,
        label: 'Edit',
      ),
      // Swipe left → delete (red background)
      secondaryBackground: _SwipeBg(
        color: colors.colorRedBox,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right → edit; don't dismiss, just navigate
          onEdit();
          return false;
        } else {
          // Swipe left → delete
          onDelete();
          return false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExcluded
                ? colors.colorGray.withOpacity(0.3)
                : isPaid
                    ? Colors.green.withOpacity(0.4)
                    : colors.colorDivider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isExcluded
                      ? colors.colorGray.withOpacity(0.15)
                      : isPaid
                          ? Colors.green.withOpacity(0.1)
                          : colors.colorSecondary,
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: TextStyle(
                      color: isExcluded
                          ? colors.colorGray
                          : isPaid
                              ? Colors.green
                              : colors.colorPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          color: isExcluded
                              ? colors.colorGray
                              : colors.colorPrimaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Grade: ${student.grade}',
                        style: TextStyle(
                            color: colors.colorSecondaryText,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${student.monthlyFee.toStringAsFixed(0)} MMK / month',
                        style: TextStyle(
                          color: isExcluded
                              ? colors.colorGray
                              : colors.colorPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: colors.colorGray, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  final AlignmentGeometry alignment;
  final String label;

  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.alignment,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}