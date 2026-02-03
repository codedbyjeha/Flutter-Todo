import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/dashboard_chart.dart';
import 'widgets/stat_card.dart';
import 'models/todo_model.dart';
import 'screens/profile_screen.dart';
import 'widgets/themed_background.dart';

class TodoWebSimple extends StatefulWidget {
  const TodoWebSimple({super.key});

  @override
  State<TodoWebSimple> createState() => _TodoWebSimpleState();
}

class _TodoWebSimpleState extends State<TodoWebSimple> {
  String _selectedCategory = 'General';
  final List<String> _categories = ['All', 'General', 'Work', 'Personal', 'Shopping', 'Health', 'Education', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final scheme = Theme.of(context).colorScheme;
          final auth = context.watch<AuthProvider>();
          final user = auth.currentUser;
          final photoBytes = _decodePhoto(user?.photoBase64);
          final allTodos = provider.allTodos;
          final visibleTodos = provider.todos;
          final int activeCount = allTodos.where((t) => !t.isCompleted).length;
          final int doneCount = allTodos.where((t) => t.isCompleted).length;
          final now = DateTime.now();
          final int overdueCount = allTodos.where((t) {
            return !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now);
          }).length;
          // final int totalCount = allTodos.length;

          // Apply Category Filter locally for the LIST view
          final displayTodos = _selectedCategory == 'All'
              ? visibleTodos
              : _selectedCategory == 'Done'
                  ? visibleTodos.where((t) => t.isCompleted).toList()
                  : visibleTodos.where((t) => t.category == _selectedCategory && !t.isCompleted).toList();

          final username = user?.username ?? 'Guest';
          return SafeArea(
            child: ThemedBackground(
              child: CustomScrollView(
                slivers: [
                // 1. Header & Greeting + Search
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $username',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your Dashboard',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => _openProfile(context),
                              child: CircleAvatar(
                                backgroundColor: scheme.secondary.withOpacity(0.3),
                                backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                                child: photoBytes == null
                                    ? Icon(Icons.person, color: scheme.primary)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // 2. Charts & Stats
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left: Pie Chart
                          Expanded(
                            flex: 3,
                            child: DashboardChart(
                              activeCount: activeCount,
                              doneCount: doneCount,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Right: Stats Grid
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                StatCard(
                                  title: 'Pending',
                                  count: activeCount.toString(),
                                  icon: Icons.timer,
                                  color: scheme.secondary,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Done',
                                  count: doneCount.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Overdue',
                                  count: overdueCount.toString(),
                                  icon: Icons.error_outline,
                                  color: scheme.error,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Category Filter
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                              if (cat == 'Done') {
                                provider.setStatusFilter('Done');
                                provider.setCategoryFilter('All');
                              } else if (cat == 'All') {
                                provider.setStatusFilter('All');
                                provider.setCategoryFilter('All');
                              } else {
                                provider.setStatusFilter('Active');
                                provider.setCategoryFilter(cat);
                              }
                            },
                            selectedColor: scheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? scheme.onPrimary : scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Theme.of(context).chipTheme.backgroundColor ?? scheme.surface),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 4. Task List Header
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),

                // 5. Task List
                displayTodos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_add, size: 60, color: scheme.primary.withOpacity(0.25)),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final todo = displayTodos[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), // reduced padding as TodoItem has its own margin
                              child: TodoItem(
                                todo: todo,
                                onChanged: (val) => provider.setCompletion(todo, val ?? false),
                                onDelete: () => provider.deleteTodo(todo.id!),
                                onTap: () => _showAddTodoDialog(context, provider: provider, todo: todo),
                              ),
                            );
                          },
                          childCount: displayTodos.length,
                        ),
                      ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          );
        },
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddTodoDialog(context, provider: provider),
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: Icon(Icons.add_task, color: Theme.of(context).colorScheme.onPrimary),
            label: Text(
              'Add Task',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 4,
            highlightElevation: 8,
          );
        },
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, {TodoProvider? provider, Todo? todo}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent for rounded corners
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTodoDialog(
          todo: todo,
          userId: provider?.userId ?? Provider.of<TodoProvider>(context, listen: false).userId,
        ),
      ),
    );

    if (!mounted) return;

    final resolvedProvider = provider ?? Provider.of<TodoProvider>(context, listen: false);

    if (result == 'delete' && todo != null) {
      await resolvedProvider.deleteTodo(todo.id!);
    } else if (result is Todo) {
      if (todo == null) {
        await resolvedProvider.addTodo(result);
      } else {
        await resolvedProvider.updateTodo(result);
      }
    }
  }

  Uint8List? _decodePhoto(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}
