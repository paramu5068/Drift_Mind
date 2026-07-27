import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Analysis', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            _buildInsightCard(
              context,
              'Routine Drift',
              'Your late-night scrolling increased by 45 minutes this week. This might be affecting your morning focus.',
              Icons.trending_up_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              context,
              'Focus Peak',
              'Your focus is strongest between 9 AM and 11 AM. Schedule your most demanding tasks then.',
              Icons.bolt_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              context,
              'Burnout Risk',
              'Low risk. Your app switching behavior has decreased, indicating better cognitive flow.',
              Icons.check_circle_rounded,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String content, IconData icon, Color accentColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
