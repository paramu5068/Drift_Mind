import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/provider/usage_provider.dart';
import '../../analytics/widgets/screen_time_chart.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../models/usage_data.dart';
import '../../../core/widgets/app_icon.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final usageStatsAsync = ref.watch(usageStatsProvider);
    final unlockCountAsync = ref.watch(unlockCountProvider);
    final focusScore = ref.watch(focusScoreProvider);
    final userNameAsync = ref.watch(userNameProvider);
    final weeklyUsageAsync = ref.watch(weeklyUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Drift Mind',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              } else if (value == 'logout') {
                ref.read(authServiceProvider).signOut();
              }
            },
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: userNameAsync.when(
                  data: (name) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${name ?? "User"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('View Profile', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  loading: () => const Text('Loading...'),
                  error: (_, _) => const Text('User'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(usageStatsProvider);
          ref.invalidate(totalScreenTimeProvider);
          ref.invalidate(unlockCountProvider);
          ref.invalidate(weeklyUsageProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Screen Time', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              weeklyUsageAsync.when(
                data: (weeklyData) => ScreenTimeChart(
                  weeklyData: weeklyData,
                  onDaySelected: (index) {},
                ),
                loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Failed to load chart: $e')),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildSmallCard(context, 'Unlocks', unlockCountAsync.when(
                    data: (count) => '$count',
                    loading: () => '--',
                    error: (_, _) => '0',
                  ), Icons.lock_open_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmallCard(context, 'Focus Score', '$focusScore%', Icons.center_focus_strong_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Top Habits', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTopAppsList(context, usageStatsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppsList(BuildContext context, AsyncValue<List<UsageData>> stats) {
    return stats.when(
      data: (data) {
        final sorted = List<UsageData>.from(data)..sort((a, b) => b.totalTimeVisible.compareTo(a.totalTimeVisible));
        return Column(children: sorted.take(5).map((app) => _buildAppItem(context, app)).toList());
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox(),
    );
  }

  Widget _buildAppItem(BuildContext context, UsageData app) {
    final duration = '${app.totalTimeVisible.inHours}h ${app.totalTimeVisible.inMinutes % 60}m';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppIcon(packageName: app.packageName, size: 48),
      title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
