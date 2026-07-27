import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/usage_provider.dart';
import '../../analytics/widgets/screen_time_chart.dart';
import '../../../models/usage_data.dart';
import '../../../core/widgets/app_icon.dart';

class UsageScreen extends ConsumerWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageStatsAsync = ref.watch(usageStatsProvider);
    final weeklyUsageAsync = ref.watch(weeklyUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Usage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(usageStatsProvider);
          ref.invalidate(weeklyUsageProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              weeklyUsageAsync.when(
                data: (weeklyData) => ScreenTimeChart(
                  weeklyData: weeklyData,
                  onDaySelected: (index) {
                    // Logic to filter list by day could go here
                  },
                ),
                loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 32),
              Text(
                'App Breakdown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAppList(context, usageStatsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppList(BuildContext context, AsyncValue<List<UsageData>> stats) {
    return stats.when(
      data: (data) {
        if (data.isEmpty) return const Center(child: Text('No usage data recorded.'));
        final sorted = List<UsageData>.from(data)..sort((a, b) => b.totalTimeVisible.compareTo(a.totalTimeVisible));
        
        return Column(
          children: sorted.map((app) => _buildAppItem(context, app)).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildAppItem(BuildContext context, UsageData app) {
    final duration = '${app.totalTimeVisible.inHours}h ${app.totalTimeVisible.inMinutes % 60}m';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppIcon(packageName: app.packageName, size: 44),
      title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
