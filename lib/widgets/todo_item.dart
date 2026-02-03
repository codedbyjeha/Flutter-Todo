import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool _isOverdue(Todo todo) {
    return !todo.isCompleted && todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = _isOverdue(todo);
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(todo.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this task?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor(todo.priority).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: onChanged,
            activeColor: scheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    todo.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.secondary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      todo.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (todo.dueDate != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          todo.isReminderActive ? Icons.alarm : Icons.calendar_today,
                          size: 12,
                          color: isOverdue ? Theme.of(context).colorScheme.error : Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, HH:mm').format(todo.dueDate!),
                          style: TextStyle(
                            fontSize: 10,
                            color: isOverdue
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  
                ],
              ),
              if (todo.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: todo.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
          trailing: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPriorityColor(todo.priority),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
