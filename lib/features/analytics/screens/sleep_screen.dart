import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/usage_provider.dart';
import 'package:intl/intl.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepStatsAsync = ref.watch(sleepStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Analysis')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(sleepStatsProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sleepStatsAsync.when(
                data: (stats) => _buildSleepScore(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 32),
              Text(
                'Sleep History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSleepLog(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepScore(BuildContext context, dynamic stats) {
    String durationText = '--';
    String rangeText = 'No data';
    
    if (stats != null) {
      final duration = stats.duration;
      durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';
      rangeText = '${DateFormat('hh:mm a').format(stats.sleepStart)} - ${DateFormat('hh:mm a').format(stats.sleepEnd)}';
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.bedtime_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Last Night', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              durationText, 
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rangeText, 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepLog(BuildContext context) {
    return Column(
      children: [
        _buildLogCard(context, 'Today', '7h 24m', '11:30 PM - 7:00 AM', 85),
        _buildLogCard(context, 'Yesterday', '8h 15m', '10:45 PM - 7:00 AM', 92),
        _buildLogCard(context, 'Sunday', '6h 45m', '12:15 AM - 7:00 AM', 74),
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, String day, String duration, String range, int quality) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.nightlight_round, color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: Theme.of(context).textTheme.titleMedium),
                  Text(range, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(duration, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('$quality Score', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
