import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/home/home_screen.dart';
import 'package:my_teacher_wallet/ui/screens/main_screen.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/payment_check_screen.dart';
import 'package:my_teacher_wallet/ui/screens/settings/settings_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/add_student/add_student_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/student_detail/student_detail_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/students_screen.dart';

enum Routes {
  root('home', '/'),
  students("students", "/students"),
  payment("payment", "/payment"),
  settings("settings", "/settings"),
  addStudents("addStudents", "/addStudents"),
  studentDetail("studentDetail", "/studentDetail");

  const Routes(this.name, this.path);
  final String name;
  final String path;
}

final GoRouter goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.root.path,
              name: Routes.root.name,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.students.path,
              name: Routes.students.name,
              builder: (context, state) => const StudentsScreen(),
              routes: [
                GoRoute(
                  path: Routes.addStudents.path,
                  name: Routes.addStudents.name,
                  builder: (context, state) => const AddStudentScreen(),
                ),
                GoRoute(
                  path: Routes.studentDetail.path,
                  name: Routes.studentDetail.name,
                  builder: (context, state) {
                    final student = state.extra as StudentEntity;
                    return StudentDetailScreen(student: student);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.payment.path,
              name: Routes.payment.name,
              builder: (context, state) => const PaymentCheckScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings.path,
              name: Routes.settings.name,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
