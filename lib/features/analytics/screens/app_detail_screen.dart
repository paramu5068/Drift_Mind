import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/usage_data.dart';
import '../../../core/widgets/app_icon.dart';
import 'package:intl/intl.dart';
import '../provider/usage_provider.dart';

class AppDetailScreen extends ConsumerWidget {
  final UsageData app;

  const AppDetailScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(appActivityProvider(app.packageName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  AppIcon(packageName: app.packageName, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    app.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    app.packageName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildStatRow(context, 'Total Time Today', _formatDuration(app.totalTimeVisible)),
            const Divider(height: 32),
            _buildStatRow(context, 'Last Used', DateFormat('hh:mm a').format(app.lastUsed)),
            const SizedBox(height: 40),
            _buildActivitySection(context, activityAsync),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes} mins';
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context, AsyncValue<List<Duration>> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Breakdown (Hours)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        activity.when(
          data: (data) {
            final maxMinutes = data.fold<double>(1.0, (max, d) {
              final m = d.inMinutes.toDouble();
              return m > max ? m : max;
            });

            return SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxMinutes * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Theme.of(context).colorScheme.primaryContainer,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} mins',
                          TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 4 != 0) return const SizedBox.shrink();
                          return Text('${value.toInt()}h', style: Theme.of(context).textTheme.labelSmall);
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index].inMinutes.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
          loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text('Error loading activity')),
        ),
      ],
    );
  }
}
