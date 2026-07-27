import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/provider/usage_provider.dart';

class FocusTab extends ConsumerWidget {
  const FocusTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusStatsAsync = ref.watch(focusStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mindset'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: focusStatsAsync.when(
        data: (stats) {
          final score = stats['focusScore'] as int;
          final interruptions = stats['interruptions'] as int;
          final longestMs = stats['longestSessionMs'] as int;
          final longestDuration = Duration(milliseconds: longestMs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Real-time Metrics', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildFocusRing(context, score),
                const SizedBox(height: 32),
                _buildStatTile(
                  context, 
                  'App Switches', 
                  '$interruptions', 
                  Icons.bolt_rounded, 
                  interruptions > 10 ? Colors.orange : Colors.green,
                  'Last 2 hours'
                ),
                const SizedBox(height: 12),
                _buildStatTile(
                  context, 
                  'Longest Flow', 
                  '${longestDuration.inMinutes}m', 
                  Icons.timer_outlined, 
                  Colors.blue,
                  'Continuous immersion'
                ),
                const SizedBox(height: 32),
                _buildAdviceCard(context, score),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Focus analysis failed: $e')),
      ),
    );
  }

  Widget _buildFocusRing(BuildContext context, int score) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 220,
            width: 220,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 20,
              strokeCap: StrokeCap.round,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: score > 70 ? Colors.blue : (score > 40 ? Colors.orange : Colors.red),
            ),
          ),
          Column(
            children: [
              Text('$score%', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Text('Focus Score', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context, int score) {
    String advice;
    if (score > 80) {
      advice = "Excellent! You're in the flow state. Keep minimizing distractions.";
    } else if (score > 50) {
      advice = "Good progress, but you're switching apps frequently. Try pomodoro.";
    } else {
      advice = "High distraction detected. Consider a digital detox for 30 minutes.";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 12),
              Text('Mindful Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Text(advice, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
