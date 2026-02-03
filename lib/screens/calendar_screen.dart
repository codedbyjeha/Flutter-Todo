import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/themed_background.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  Map<DateTime, List<Todo>> _groupByDate(List<Todo> todos) {
    final Map<DateTime, List<Todo>> groups = {};
    for (final todo in todos) {
      if (todo.dueDate == null) continue;
      final d = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      groups.putIfAbsent(d, () => []).add(todo);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todosWithDate = provider.allTodos.where((t) => t.dueDate != null).toList();
        todosWithDate.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        final grouped = _groupByDate(todosWithDate);
        final dates = grouped.keys.toList()..sort();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Calendar / Agenda'),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
          body: ThemedBackground(
            child: dates.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada task dengan due date',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    ),
                  )
                : ListView.builder(
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final items = grouped[date]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(date),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...items.map(
                              (todo) => TodoItem(
                                todo: todo,
                                onChanged: (val) => provider.setCompletion(todo, val ?? false),
                                onDelete: () => provider.deleteTodo(todo.id!),
                                onTap: () => _showAddTodoDialog(context, todo: todo, userId: provider.userId),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, {required int userId, Todo? todo}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTodoDialog(todo: todo, userId: userId),
      ),
    );

    if (!context.mounted) return;
    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (result == 'delete' && todo != null) {
      await provider.deleteTodo(todo.id!);
    } else if (result is Todo) {
      if (todo == null) {
        await provider.addTodo(result);
      } else {
        await provider.updateTodo(result);
      }
    }
  }
}
