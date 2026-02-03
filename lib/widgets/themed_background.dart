import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeName = context.watch<ThemeProvider>().themeName;
    if (themeName == 'pink') {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFDCE8),
              Color(0xFFFFC3DA),
              Color(0xFFFFF4F8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      );
    }
    return child;
  }
}
