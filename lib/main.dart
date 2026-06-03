import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_config.dart';
import 'package:my_teacher_wallet/core/services/isar_service.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/core/theme/theme_provider.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  final isarInstance = await isarService.db;
  
  String supabaseUrl = AppConfig.supabaseUrl;
  String supabaseKey = AppConfig.supabaseKey;
  await Supabase.initialize(url: supabaseUrl,anonKey: supabaseKey);

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(isarInstance),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF1672EC),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1672EC),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
      ),
    );
  }
}