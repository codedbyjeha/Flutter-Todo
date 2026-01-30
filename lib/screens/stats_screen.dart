import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.allTodos;
        final categories = <String, int>{};
        for (final t in todos) {
          categories[t.category] = (categories[t.category] ?? 0) + 1;
        }
        final labels = categories.keys.toList()..sort();
        final maxY = categories.values.isEmpty ? 1 : (categories.values.reduce((a, b) => a > b ? a : b)).toDouble();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            title: const Text('Statistik Produktivitas'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black87,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data statistik',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagram Batang per Kategori',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            maxY: maxY + 1,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        labels[idx],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(labels.length, (i) {
                              final label = labels[i];
                              final count = categories[label] ?? 0;
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: count.toDouble(),
                                    width: 18,
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
