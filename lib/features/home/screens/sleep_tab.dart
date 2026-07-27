import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../analytics/provider/usage_provider.dart';

class SleepTab extends ConsumerWidget {
  const SleepTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepStatsAsync = ref.watch(sleepStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sleepStatsAsync.when(
        data: (sleep) {
          if (sleep == null) return _buildNoData(context);
          
          final duration = sleep.duration;
          final start = sleep.sleepStart;
          final end = sleep.sleepEnd;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last Night', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 24),
                _buildSleepSummaryCard(context, duration, start, end),
                const SizedBox(height: 32),
                Text('Sleep Quality', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildQualityMetric(context, 'Total Rest', '${duration.inHours}h ${duration.inMinutes % 60}m', Icons.bedtime_rounded, Colors.indigo),
                const Divider(),
                _buildQualityMetric(context, 'Fell Asleep', DateFormat('hh:mm a').format(start), Icons.nightlight_round, Colors.deepPurple),
                const Divider(),
                _buildQualityMetric(context, 'Woke Up', DateFormat('hh:mm a').format(end), Icons.wb_sunny_rounded, Colors.orange),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Analysis failed: $e')),
      ),
    );
  }

  Widget _buildNoData(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          const Text('Analyzing your sleep patterns...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Wear your device to bed for better results.', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSleepSummaryCard(BuildContext context, Duration duration, DateTime start, DateTime end) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: CircularProgressIndicator(
                    value: (duration.inMinutes / 480).clamp(0.0, 1.0),
                    strokeWidth: 16,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                Column(
                  children: [
                    Text('${duration.inHours}h ${duration.inMinutes % 60}m', 
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Text('Total Sleep', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimePoint('Bedtime', start),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildTimePoint('Wake up', end),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePoint(String label, DateTime time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(DateFormat('hh:mm a').format(time), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQualityMetric(BuildContext context, String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
