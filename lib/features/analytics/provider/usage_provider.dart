import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/usage_data.dart';
import '../../../models/wellness_data.dart';
import '../../../services/native_tracking/usage_service.dart';
import '../../../services/firebase/firebase_sync_service.dart';
import '../../../services/ai/gemini_service.dart';
import 'package:intl/intl.dart';

final usageServiceProvider = Provider((ref) => UsageService());
final geminiServiceProvider = Provider((ref) => GeminiService());

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  final usageService = ref.watch(usageServiceProvider);
  final syncService = FirebaseSyncService(usageService);
  syncService.initialize();
  ref.onDispose(() => syncService.dispose());
  return syncService;
});

final usageStatsProvider = FutureProvider<List<UsageData>>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getDailyUsageStats();
});

final totalScreenTimeProvider = StreamProvider<Duration>((ref) {
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return syncService.liveScreenTimeStream;
});

final weeklyUsageProvider = FutureProvider<List<Duration>>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getWeeklyUsage();
});

final appActivityProvider = FutureProvider.family<List<Duration>, String>((ref, packageName) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getAppActivity(packageName);
});

final unlockCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getUnlockCount();
});

final sleepStatsProvider = FutureProvider<SleepData?>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getSleepStats();
});

final focusStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.getFocusStats();
});

final focusScoreProvider = Provider<int>((ref) {
  final statsAsync = ref.watch(focusStatsProvider);
  return statsAsync.when(
    data: (stats) => (stats['focusScore'] as num).toInt(),
    loading: () => 100,
    error: (error, stack) => 100,
  );
});

final aiInsightsProvider = FutureProvider<String>((ref) async {
  ref.keepAlive();
  final gemini = ref.read(geminiServiceProvider);
  final usageService = ref.read(usageServiceProvider);

  final usage = await usageService.getDailyUsageStats();
  Duration sot = await usageService.getTotalScreenTime();

  if (sot == Duration.zero && usage.isNotEmpty) {
    int totalMs = 0;
    for (var u in usage) {
      totalMs += u.totalTimeVisible.inMilliseconds;
    }
    sot = Duration(milliseconds: totalMs);
  }

  final unlocks = await usageService.getUnlockCount();
  final focus = await usageService.getFocusStats();
  final sleep = await usageService.getSleepStats();

  final topApps = usage.take(5).map((e) => {
    'name': e.appName,
    'duration': '${e.totalTimeVisible.inHours}h ${e.totalTimeVisible.inMinutes % 60}m'
  }).toList();

  final sleepMap = {
    'duration': sleep != null ? '${sleep.duration.inHours}h ${sleep.duration.inMinutes % 60}m' : 'Unknown',
    'start': sleep != null ? DateFormat('hh:mm a').format(sleep.sleepStart) : 'Unknown',
    'end': sleep != null ? DateFormat('hh:mm a').format(sleep.sleepEnd) : 'Unknown',
  };

  return await gemini.generateWellnessInsights(
    totalScreenTime: sot,
    topApps: topApps,
    unlockCount: unlocks,
    focusStats: focus,
    sleepStats: sleepMap,
  );
});

final permissionProvider = StateProvider<bool>((ref) => false);
