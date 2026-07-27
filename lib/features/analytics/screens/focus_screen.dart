import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/provider/usage_provider.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusStatsAsync = ref.watch(focusStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Patterns')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(focusStatsProvider);
        },
        child: focusStatsAsync.when(
          data: (stats) {
            final score = stats['focusScore'] as int;
            final interruptions = stats['interruptions'] as int;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFocusSummary(context, score),
                  const SizedBox(height: 32),
                  _buildInterruptionCard(context, interruptions),
                  const SizedBox(height: 32),
                  Text('Daily Focus Rhythm', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  _buildFocusHeatmap(context),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildFocusSummary(BuildContext context, int score) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus Score', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('$score%', style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
            ),
            const Icon(Icons.center_focus_strong_rounded, size: 64, color: Color(0xFF4352A5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInterruptionCard(BuildContext context, int interruptions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interruptions', style: Theme.of(context).textTheme.labelLarge),
                  Text('$interruptions app switches in the last hour', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusHeatmap(BuildContext context) {
    return Column(
      children: [
        _buildHourRow(context, 'Morning', '8 AM - 12 PM', 0.9),
        _buildHourRow(context, 'Afternoon', '12 PM - 5 PM', 0.4),
        _buildHourRow(context, 'Evening', '5 PM - 10 PM', 0.6),
        _buildHourRow(context, 'Night', '10 PM - 2 AM', 0.2),
      ],
    );
  }

  Widget _buildHourRow(BuildContext context, String time, String range, double intensity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: Theme.of(context).textTheme.titleMedium),
              Text(range, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: intensity,
              minHeight: 12,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
