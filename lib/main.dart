import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/ui/screens/home/home_screen.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}