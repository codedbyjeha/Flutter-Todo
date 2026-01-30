import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/dashboard_chart.dart';
import 'widgets/stat_card.dart';
import 'models/todo_model.dart';

class TodoWebSimple extends StatefulWidget {
  const TodoWebSimple({super.key});

  @override
  State<TodoWebSimple> createState() => _TodoWebSimpleState();
}

class _TodoWebSimpleState extends State<TodoWebSimple> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Work', 'Personal', 'Shopping', 'Health', 'Education'];
  final List<String> _priorities = ['All', 'Low', 'Medium', 'High'];
  final List<String> _repeatRules = ['All', 'None', 'Daily', 'Weekly'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Modern light bg
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final allTodos = provider.allTodos;
          final visibleTodos = provider.todos;
          final int activeCount = allTodos.where((t) => !t.isCompleted).length;
          final int doneCount = allTodos.where((t) => t.isCompleted).length;
          // final int totalCount = allTodos.length;

          // Apply Category Filter locally for the LIST view
          final displayTodos = _selectedCategory == 'All'
              ? visibleTodos
              : visibleTodos.where((t) => t.category == _selectedCategory).toList();

          final username = Provider.of<AuthProvider>(context, listen: false).currentUser?.username ?? 'Guest';
          return SafeArea(
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
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Your Dashboard',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: const Icon(Icons.person, color: Colors.indigo),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                onChanged: provider.setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _openFilters(context, provider),
                              icon: const Icon(Icons.tune),
                              tooltip: 'Filters',
                            ),
                          ],
                        ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
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
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Done',
                                  count: doneCount.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.green,
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
                              provider.setCategoryFilter(cat);
                            },
                            selectedColor: Colors.indigo,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.indigo.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.indigo.shade50),
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
                        TextButton(
                          onPressed: () {
                             // Reset filter in provider if needed, or open full list page
                             Provider.of<TodoProvider>(context, listen: false).setStatusFilter('All');
                             // Just for demo, we are showing all tasks in this list anyway
                          },
                          child: const Text('See All'),
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
                              Icon(Icons.assignment_add, size: 60, color: Colors.indigo.shade100),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(color: Colors.grey.shade400),
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
          );
        },
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddTodoDialog(context, provider: provider),
            backgroundColor: Colors.indigo,
            icon: const Icon(Icons.add_task, color: Colors.white),
            label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  void _openFilters(BuildContext context, TodoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tags = provider.allTodos.expand((t) => t.tags).toSet().toList();
        final selectedTags = <String>{}..addAll(provider.selectedTags);
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Advanced Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Status'),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Active', 'Done']
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s),
                              selected: provider.statusFilter == s,
                              onSelected: (_) => provider.setStatusFilter(s),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Priority'),
                    Wrap(
                      spacing: 8,
                      children: _priorities
                          .map(
                            (p) => ChoiceChip(
                              label: Text(p),
                              selected: provider.priorityFilter == p,
                              onSelected: (_) => provider.setPriorityFilter(p),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Repeat'),
                    Wrap(
                      spacing: 8,
                      children: _repeatRules
                          .map(
                            (r) => ChoiceChip(
                              label: Text(r),
                              selected: provider.repeatFilter == r,
                              onSelected: (_) => provider.setRepeatFilter(r),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Only overdue'),
                            value: provider.showOverdueOnly,
                            onChanged: (val) => provider.setOverdueOnly(val),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Due today'),
                            value: provider.showTodayOnly,
                            onChanged: (val) => provider.setTodayOnly(val),
                          ),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Tags'),
                      Wrap(
                        spacing: 8,
                        children: tags
                            .map(
                              (tag) => FilterChip(
                                label: Text('#$tag'),
                                selected: selectedTags.contains(tag),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedTags.add(tag);
                                    } else {
                                      selectedTags.remove(tag);
                                    }
                                  });
                                  provider.setSelectedTags(selectedTags);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
