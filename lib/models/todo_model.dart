import 'dart:convert';

class Todo {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final bool isReminderActive;
  final String priority; // 'High', 'Medium', 'Low'
  final String category; // 'General', 'Work', 'Personal', etc.
  final String repeatRule; // 'None', 'Daily', 'Weekly'
  final List<String> tags; // multi-label

  Todo({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.isReminderActive = false,
    this.priority = 'Medium',
    this.category = 'General',
    this.repeatRule = 'None',
    this.tags = const [],
  });

  // Convert a Todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isReminderActive': isReminderActive ? 1 : 0,
      'priority': priority,
      'category': category,
      'repeatRule': repeatRule,
      'tags': jsonEncode(tags),
    };
  }

  // Implement toString to make it easier to see information about
  // each todo when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, isCompleted: $isCompleted, priority: $priority}';
  }

  // Extract a Todo object from separate Map object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      userId: map['userId'] ?? 0,
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      isReminderActive: map['isReminderActive'] == 1,
      priority: map['priority'] ?? 'Medium',
      category: map['category'] ?? 'General',
      repeatRule: map['repeatRule'] ?? 'None',
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? List<String>.from(jsonDecode(map['tags']))
          : const [],
    );
  }

  // Create a copy of Todo with some updated values
  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    bool? isReminderActive,
    String? priority,
    String? category,
    String? repeatRule,
    List<String>? tags,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      isReminderActive: isReminderActive ?? this.isReminderActive,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      repeatRule: repeatRule ?? this.repeatRule,
      tags: tags ?? this.tags,
    );
  }
}
