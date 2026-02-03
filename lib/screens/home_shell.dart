import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../screens/calendar_screen.dart';
import '../screens/stats_screen.dart';
import '../todo_web_simple.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return ChangeNotifierProvider(
      create: (_) => TodoProvider(userId: user.id!),
      child: Builder(
        builder: (context) {
          final pages = [
            const TodoWebSimple(),
            const CalendarScreen(),
            const StatsScreen(),
          ];

          return Scaffold(
            body: pages[_index],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
              ],
            ),
          );
        },
      ),
    );
  }
}
