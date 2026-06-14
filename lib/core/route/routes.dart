import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/auth/create_account_screen.dart';
import 'package:my_teacher_wallet/ui/screens/auth/log_in_screen.dart';
import 'package:my_teacher_wallet/ui/screens/home/home_screen.dart';
import 'package:my_teacher_wallet/ui/screens/main_screen.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/payment_check_screen.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/report_screen.dart';
import 'package:my_teacher_wallet/ui/screens/settings/about_screen.dart';
import 'package:my_teacher_wallet/ui/screens/settings/app_info_screen.dart';
import 'package:my_teacher_wallet/ui/screens/settings/settings_screen.dart';
import 'package:my_teacher_wallet/ui/screens/splash/splash_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/add_student/add_student_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/edit_student/edit_student_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/student_detail/student_detail_screen.dart';
import 'package:my_teacher_wallet/ui/screens/student/students_screen.dart';

enum Routes {
  root('home', '/'),
  students("students", "/students"),
  payment("payment", "/payment"),
  settings("settings", "/settings"),
  addStudents("addStudents", "addStudents"),
  studentDetail("studentDetail", "studentDetail"),
  editStudent("editStudent", "editStudent"),
  reports("reports", "/reports"),
  about("about", "/about"),
  appInfo("appInfo", "/appInfo"),
  splash("splash", "/splash"),
  login("login", "/login"),
  createAccount("createAccount", "/createAccount");

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
              path: Routes.splash.path,
              name: Routes.splash.name,
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: Routes.login.path,
              name: Routes.login.name,
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: Routes.createAccount.path,
              name: Routes.createAccount.name,
              builder: (context, state) => const CreateAccountScreen(),
            ),
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
                  routes: [
                    GoRoute(
                      path: Routes.editStudent.path,
                      name: Routes.editStudent.name,
                      builder: (context, state) {
                        final student = state.extra as StudentEntity;
                        return EditStudentScreen(student: student);
                      },
                    ),
                  ],
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
              routes: [
                GoRoute(
                  path: Routes.reports.path,
                  name: Routes.reports.name,
                  builder: (context, state) => const ReportScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings.path,
              name: Routes.settings.name,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: Routes.about.path,
                  name: Routes.about.name,
                  builder: (context, state) => const AboutScreen(),
                ),
                GoRoute(
                  path: Routes.appInfo.path,
                  name: Routes.appInfo.name,
                  builder: (context, state) => const AppInfoScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
