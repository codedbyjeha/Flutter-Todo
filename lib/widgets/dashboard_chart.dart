import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final int doneCount;
  final int activeCount;

  const DashboardChart({
    super.key,
    required this.doneCount,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if chart is empty
    final bool isEmpty = doneCount == 0 && activeCount == 0;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: isEmpty
                  ? [
                      PieChartSectionData(
                        color: Colors.grey.shade300,
                        value: 1,
                        title: '',
                        radius: 20,
                      )
                    ]
                  : [
                      PieChartSectionData(
                        color: Colors.indigoAccent,
                        value: activeCount.toDouble(),
                        title: '${((activeCount / (activeCount + doneCount)) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.greenAccent,
                        value: doneCount.toDouble(),
                        title: '${((doneCount / (activeCount + doneCount)) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${activeCount + doneCount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
