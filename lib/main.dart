import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          final baseTheme = context.watch<ThemeProvider>().themeData;
          final theme = baseTheme.copyWith(
            textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
          );
          return AnimatedTheme(
            data: theme,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: MaterialApp(
              title: 'DM Todo',
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.isLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return auth.currentUser == null ? const LoginScreen() : const HomeShell();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
