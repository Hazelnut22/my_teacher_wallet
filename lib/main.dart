import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_teacher_wallet/core/app_config.dart';
import 'package:my_teacher_wallet/core/app_flavor.dart';
import 'package:my_teacher_wallet/core/services/auth_service.dart';
import 'package:my_teacher_wallet/core/services/isar_service.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/core/theme/theme_provider.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  final isarInstance = await isarService.db;

  String supabaseUrl = AppFlavor.baseUrl;
  String supabaseKey = AppConfig.supabaseKey;
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(isarInstance)],
      child: MyApp(),
    ),
  );
}

void initGoogleSignIn() {
  final GoogleSignIn signIn = GoogleSignIn.instance;

  unawaited(
    signIn
        .initialize(
          clientId: AuthService.androidClientId,
          serverClientId: AuthService.webClientId,
        )
        .then((_) {
          // Optional: Listen to global authentication events if you prefer reactive streams
          signIn.authenticationEvents.listen((event) {
            // Handle global changes here if necessary
          });

          // Silently signs the user back in if a valid token is cached
          signIn.attemptLightweightAuthentication();
        }),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = createRouter(ref);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
