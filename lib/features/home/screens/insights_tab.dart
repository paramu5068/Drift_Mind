import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/provider/usage_provider.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiInsightsAsync = ref.watch(aiInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(aiInsightsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: aiInsightsAsync.when(
        data: (insights) => _buildInsightsContent(context, insights),
        loading: () => _buildLoadingState(context),
        error: (e, _) => _buildErrorState(context, ref, e.toString()),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text('AI Coach is thinking...', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Analyzing your daily patterns', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Connection Lost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('The AI coach needs an internet connection to provide insights.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(aiInsightsProvider),
              child: const Text('Retry Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, String text) {
    final insights = _parsePoints(text, 'Insights');
    final recommendations = _parsePoints(text, 'Recommendations');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIBanner(context),
          const SizedBox(height: 32),
          if (insights.isNotEmpty) ...[
            _buildSectionHeader(context, 'Key Insights', Icons.auto_awesome_rounded, Colors.blue),
            const SizedBox(height: 16),
            ...insights.map((point) => _buildPointCard(context, point, Colors.blue)),
            const SizedBox(height: 24),
          ],
          if (recommendations.isNotEmpty) ...[
            _buildSectionHeader(context, 'Action Plan', Icons.lightbulb_outline_rounded, Colors.amber),
            const SizedBox(height: 16),
            ...recommendations.map((point) => _buildPointCard(context, point, Colors.amber)),
          ],
        ],
      ),
    );
  }

  List<String> _parsePoints(String text, String sectionName) {
    final lines = text.split('\n');
    bool inSection = false;
    List<String> points = [];

    for (var line in lines) {
      if (line.toLowerCase().contains(sectionName.toLowerCase())) {
        inSection = true;
        continue;
      }
      if (inSection && (line.toLowerCase().contains('insights') || line.toLowerCase().contains('recommendations')) && !line.toLowerCase().contains(sectionName.toLowerCase())) {
        break;
      }
      
      if (inSection) {
        final match = RegExp(r'^\d+\.\s*(.*)').firstMatch(line.trim());
        if (match != null) {
          points.add(match.group(1)!);
        } else if (line.trim().isNotEmpty && !line.trim().startsWith('*')) {
           if (!line.contains(':')) points.add(line.trim());
        }
      }
    }
    return points;
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPointCard(BuildContext context, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.1), width: 1),
        ),
        color: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded, color: Colors.white, size: 48),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gemini 3 Flash', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Real-time Coaching', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
