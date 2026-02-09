import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/isar_service.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  final isarInstance = await isarService.db;
  
  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(isarInstance),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}