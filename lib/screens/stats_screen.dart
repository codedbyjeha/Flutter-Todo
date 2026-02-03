import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/themed_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.allTodos;
        final now = DateTime.now();
        final doneCount = todos.where((t) => t.isCompleted).length;
        final activeCount = todos.where((t) => !t.isCompleted).length;
        final overdueCount = todos.where((t) {
          return !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now);
        }).length;

        final statusLabels = ['Active', 'Done', 'Overdue'];
        final statusValues = [
          activeCount.toDouble(),
          doneCount.toDouble(),
          overdueCount.toDouble(),
        ];
        final statusColors = [
          Colors.blue,
          Colors.green,
          Colors.red,
        ];
        final maxY = statusValues.isEmpty ? 1.0 : statusValues.reduce((a, b) => a > b ? a : b) + 1;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: scheme.background,
          appBar: AppBar(
            title: const Text('Statistik Produktivitas'),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
          body: ThemedBackground(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: todos.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada data statistik',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      ),
                    )
                  : ListView(
                      children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${todos.length} total task',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _MiniStat(label: 'Done', value: doneCount.toString(), color: Colors.green),
                                const SizedBox(width: 12),
                                _MiniStat(label: 'Active', value: activeCount.toString(), color: scheme.primary),
                                const SizedBox(width: 12),
                                _MiniStat(label: 'Overdue', value: overdueCount.toString(), color: scheme.error),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Statistik Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? scheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  maxY: maxY,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: scheme.onSurface.withOpacity(0.08),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: scheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= statusLabels.length) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              statusLabels[idx],
                                              style: TextStyle(fontSize: 10, color: scheme.onSurface),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(statusLabels.length, (i) {
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: statusValues[i],
                                          width: 18,
                                          color: statusColors[i],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: List.generate(statusLabels.length, (i) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: statusColors[i],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(statusLabels[i], style: const TextStyle(fontSize: 12)),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ringkasan Cepat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickCard(label: 'Overdue', value: overdueCount.toString(), color: scheme.error),
                          _QuickCard(label: 'Done', value: doneCount.toString(), color: Colors.green),
                          _QuickCard(label: 'Active', value: activeCount.toString(), color: scheme.primary),
                        ],
                      ),
                    ],
                  ),
          ),
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.circle, size: 10, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
