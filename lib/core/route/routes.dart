import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/ui/screens/home/home_screen.dart';

enum Routes {
  root('home','/');
  const Routes(this.name,this.path);
  final String name;
  final String path;
}

final GoRouter goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: Routes.root.name,
      path: Routes.root.path,
      builder: (context, state) => HomeScreen(),
    ),
  ],
);