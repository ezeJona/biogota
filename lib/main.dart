import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'backend-api/init_supabase.dart';
import 'pages/home/home_page.dart';
import 'pages/start_page.dart';
import 'pages/user/login_page.dart';
import 'pages/user/setup_profile_page.dart';
import 'pages/user/sign_up_page.dart';
import 'providers/init_hive.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();
  await initSupabase();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biogota',
      theme: AppTheme.theme,
      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/login/sign-up': (context) => const SignUpPage(),
        '/setup-profile': (context) => const SetupProfilePage(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
    );
  }
}
