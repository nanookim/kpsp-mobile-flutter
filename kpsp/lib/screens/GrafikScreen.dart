import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GrafikScreen extends StatelessWidget {
  final String childName;
  final List<Map<String, dynamic>> screenings;

  const GrafikScreen({
    super.key,
    required this.childName,
    required this.screenings,
  });

  @override
  Widget build(BuildContext context) {
    // Urutkan berdasarkan tanggal skrining
    final sortedScreenings = [...screenings];
    sortedScreenings.sort(
      (a, b) => DateTime.parse(
        a['tanggal_skrining'],
      ).compareTo(DateTime.parse(b['tanggal_skrining'])),
    );

    // Cari skor maksimum untuk maxY
    final maxScore = sortedScreenings.isNotEmpty
        ? sortedScreenings
              .map((s) => (s['skor_mentah'] ?? 0).toDouble())
              .reduce((a, b) => a > b ? a : b)
        : 10.0;

    // Buat barGroups
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < sortedScreenings.length; i++) {
      final s = sortedScreenings[i];
      final score = (s['skor_mentah'] ?? 0).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: score,
              color: Colors.blueAccent,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Grafik Skrining $childName"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: screenings.isEmpty
            ? Center(
                child: Text(
                  "Belum ada data skrining",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            : BarChart(
                BarChartData(
                  maxY: maxScore + 5,
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final s = sortedScreenings[group.x.toInt()];
                        final date = DateTime.parse(s['tanggal_skrining']);
                        final score = s['skor_mentah'] ?? 0;
                        return BarTooltipItem(
                          "${DateFormat('dd MMM yyyy').format(date)}\nSkor: $score",
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxScore / 5,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= sortedScreenings.length)
                            return const SizedBox();
                          final date = DateTime.parse(
                            sortedScreenings[index]['tanggal_skrining'],
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('MMM yy').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxScore / 5,
                  ),
                ),
              ),
      ),
    );
  }
}
