import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class AddTodoDialog extends StatefulWidget {
  final Todo? todo;
  final int userId;

  const AddTodoDialog({super.key, this.todo, required this.userId});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isReminderActive = false;
  String _priority = 'Medium';
  String _category = 'General';

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _categories = ['General', 'Work', 'Personal', 'Shopping', 'Health', 'Education'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _tagsController = TextEditingController(text: widget.todo?.tags.join(', ') ?? '');
    
    if (widget.todo != null) {
      _isReminderActive = widget.todo!.isReminderActive;
      _priority = widget.todo!.priority;
      _category = widget.todo!.category;
      if (widget.todo!.dueDate != null) {
        _selectedDate = widget.todo!.dueDate;
        _selectedTime = TimeOfDay.fromDateTime(widget.todo!.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      if (!mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
          _isReminderActive = true; // Auto-enable reminder if time is picked
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.todo == null ? 'New Task' : 'Edit Task',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      items: _priorities.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (pisahkan dengan koma)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
                title: Text(_selectedDate == null
                    ? 'Set Reminder'
                    : 'Remind me on ${DateFormat('MMM d, HH:mm').format(
                        DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        ),
                      )}'),
                trailing: Switch(
                  value: _isReminderActive,
                  onChanged: (val) {
                    setState(() {
                      _isReminderActive = val;
                      if (val && _selectedDate == null) {
                        _pickDateTime();
                      }
                    });
                  },
                ),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    DateTime? finalDueDate;
                    if (_selectedDate != null && _selectedTime != null) {
                      finalDueDate = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                    }

                    final newTodo = Todo(
                      id: widget.todo?.id,
                      userId: widget.todo?.userId ?? widget.userId,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      createdAt: widget.todo?.createdAt ?? DateTime.now(),
                      isCompleted: widget.todo?.isCompleted ?? false,
                      dueDate: finalDueDate,
                      isReminderActive: _isReminderActive,
                      priority: _priority,
                      category: _category,
                      repeatRule: 'None',
                      tags: _tagsController.text
                          .split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toSet()
                          .toList(),
                    );

                    Navigator.pop(context, newTodo);
                  }
                },
                child: const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (widget.todo != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final bool? confirm = await showDialog<bool>(
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

                    if (confirm == true && mounted) {
                      Navigator.pop(context, 'delete');
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
