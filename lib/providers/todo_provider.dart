import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationHelper _notificationHelper = NotificationHelper();

  List<Todo> _todos = [];
  final int userId;

  String _statusFilter = 'All'; // 'All', 'Active', 'Done'
  String _categoryFilter = 'All';
  String _priorityFilter = 'All';
  String _repeatFilter = 'All';
  String _searchQuery = '';
  bool _showOverdueOnly = false;
  bool _showTodayOnly = false;
  final Set<String> _selectedTags = {};

  String get statusFilter => _statusFilter;
  String get categoryFilter => _categoryFilter;
  String get priorityFilter => _priorityFilter;
  String get repeatFilter => _repeatFilter;
  bool get showOverdueOnly => _showOverdueOnly;
  bool get showTodayOnly => _showTodayOnly;
  Set<String> get selectedTags => Set.unmodifiable(_selectedTags);

  List<Todo> get allTodos => List.unmodifiable(_todos);

  List<Todo> get todos {
    List<Todo> filtered = List.from(_todos);
    if (_statusFilter == 'Active') {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    } else if (_statusFilter == 'Done') {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    }

    if (_categoryFilter != 'All') {
      filtered = filtered.where((todo) => todo.category == _categoryFilter).toList();
    }

    if (_priorityFilter != 'All') {
      filtered = filtered.where((todo) => todo.priority == _priorityFilter).toList();
    }

    if (_repeatFilter != 'All') {
      filtered = filtered.where((todo) => todo.repeatRule == _repeatFilter).toList();
    }

    if (_showOverdueOnly) {
      filtered = filtered.where((todo) => _isOverdue(todo)).toList();
    }

    if (_showTodayOnly) {
      filtered = filtered.where((todo) => _isDueToday(todo)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((todo) {
        final inTitle = todo.title.toLowerCase().contains(q);
        final inDesc = todo.description.toLowerCase().contains(q);
        final inTags = todo.tags.any((t) => t.toLowerCase().contains(q));
        return inTitle || inDesc || inTags;
      }).toList();
    }

    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((todo) {
        return _selectedTags.every((tag) => todo.tags.contains(tag));
      }).toList();
    }

    _sortTodos(filtered);
    return filtered;
  }

  TodoProvider({required this.userId}) {
    _notificationHelper.init(); // Initialize notifications
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      _todos = await _dbHelper.getTodos(userId);
      _sortTodos(_todos);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final Todo safeTodo = todo.userId == 0 ? todo.copyWith(userId: userId) : todo;
      int id = await _dbHelper.insertTodo(safeTodo);
      // If there is a due date and reminder is active, schedule notification
      if (safeTodo.dueDate != null && safeTodo.isReminderActive) {
        await _notificationHelper.scheduleNotification(
          id,
          'Reminder: ${safeTodo.title}',
          safeTodo.description.isNotEmpty ? safeTodo.description : 'It\'s time for your task!',
          safeTodo.dueDate!,
        );
      }
      await loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _dbHelper.updateTodo(todo);
      
      // Update notification
      if (todo.dueDate != null && todo.isReminderActive) {
        // Cancel old one just in case and schedule new
         await _notificationHelper.cancelNotification(todo.id!);
         await _notificationHelper.scheduleNotification(
          todo.id!,
          'Reminder: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'It\'s time for your task!',
          todo.dueDate!,
        );
      } else {
        // If reminder turned off, cancel it
        await _notificationHelper.cancelNotification(todo.id!);
      }

      await loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    await _notificationHelper.cancelNotification(id);
    await loadTodos();
  }

  Future<void> toggleTodo(Todo todo) async {
    await setCompletion(todo, !todo.isCompleted);
  }

  Future<void> setCompletion(Todo todo, bool isCompleted) async {
    final bool wasCompleted = todo.isCompleted;
    final newTodo = todo.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );
    await updateTodo(newTodo);

    if (!wasCompleted && isCompleted && todo.repeatRule != 'None') {
      final DateTime base = todo.dueDate ?? DateTime.now();
      final DateTime nextDue = todo.repeatRule == 'Daily'
          ? base.add(const Duration(days: 1))
          : base.add(const Duration(days: 7));
      final Todo repeated = todo.copyWith(
        id: null,
        isCompleted: false,
        completedAt: null,
        createdAt: DateTime.now(),
        dueDate: nextDue,
      );
      await addTodo(repeated);
    }
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String filter) {
    _categoryFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(String filter) {
    _priorityFilter = filter;
    notifyListeners();
  }

  void setRepeatFilter(String filter) {
    _repeatFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setOverdueOnly(bool value) {
    _showOverdueOnly = value;
    notifyListeners();
  }

  void setTodayOnly(bool value) {
    _showTodayOnly = value;
    notifyListeners();
  }

  void setSelectedTags(Set<String> tags) {
    _selectedTags
      ..clear()
      ..addAll(tags);
    notifyListeners();
  }

  bool _isOverdue(Todo todo) {
    return !todo.isCompleted && todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now());
  }

  bool _isDueToday(Todo todo) {
    if (todo.dueDate == null) return false;
    final now = DateTime.now();
    return todo.dueDate!.year == now.year &&
        todo.dueDate!.month == now.month &&
        todo.dueDate!.day == now.day;
  }

  void _sortTodos(List<Todo> list) {
    int priorityWeight(String p) {
      if (p == 'High') return 3;
      if (p == 'Medium') return 2;
      return 1;
    }

    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      final aOver = _isOverdue(a);
      final bOver = _isOverdue(b);
      if (aOver != bOver) return aOver ? -1 : 1;

      final aDue = a.dueDate ?? DateTime(2100);
      final bDue = b.dueDate ?? DateTime(2100);
      final dueCompare = aDue.compareTo(bDue);
      if (dueCompare != 0) return dueCompare;

      final priorityCompare = priorityWeight(b.priority) - priorityWeight(a.priority);
      if (priorityCompare != 0) return priorityCompare;

      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
