import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../widgets/themed_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: ThemedBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Logged in as'),
              subtitle: Text(auth.currentUser?.username ?? '-'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
