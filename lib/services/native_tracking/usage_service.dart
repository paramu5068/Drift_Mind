import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/usage_data.dart';
import '../../models/wellness_data.dart';

class UsageService {
  static const _channel = MethodChannel('com.driftmind.app/usage_stats');

  Future<bool> hasPermission() async {
    if (kIsWeb) return true;
    try {
      final bool hasPermission = await _channel.invokeMethod('hasPermission');
      return hasPermission;
    } catch (e) {
      debugPrint("Failed to check permission: '$e'.");
      return false;
    }
  }

  Future<void> openSettings() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('openSettings');
    } catch (e) {
      debugPrint("Failed to open settings: '$e'.");
    }
  }

  Future<List<UsageData>> getDailyUsageStats() async {
    if (kIsWeb) {
      return _getWebDailyUsageStats();
    }
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getDailyUsageStats');
      if (stats == null) return _getWebDailyUsageStats();
      return stats.map((item) => UsageData.fromMap(item as Map)).toList();
    } catch (e) {
      debugPrint("Failed to get usage stats: '$e'.");
      return _getWebDailyUsageStats();
    }
  }

  Future<Duration> getTotalScreenTime() async {
    if (kIsWeb) {
      return const Duration(hours: 5, minutes: 45);
    }
    try {
      final int ms = await _channel.invokeMethod('getTotalScreenTime');
      return Duration(milliseconds: ms);
    } catch (e) {
      debugPrint("Failed to get total screen time: '$e'.");
      return const Duration(hours: 5, minutes: 45);
    }
  }

  Future<List<Duration>> getWeeklyUsage() async {
    if (kIsWeb) {
      return _getWebWeeklyUsage();
    }
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getWeeklyUsage');
      if (stats == null) return _getWebWeeklyUsage();
      return stats.map((item) => Duration(milliseconds: item as int)).toList();
    } catch (e) {
      debugPrint("Failed to get weekly usage: '$e'.");
      return _getWebWeeklyUsage();
    }
  }

  Future<List<Duration>> getAppActivity(String packageName) async {
    if (kIsWeb) {
      return List.generate(24, (index) {
        if (index >= 9 && index <= 18) {
          return Duration(minutes: (15 + (index * 7) % 35));
        }
        return Duration.zero;
      });
    }
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getAppActivity', {'packageName': packageName});
      if (stats == null) return List.filled(24, Duration.zero);
      return stats.map((item) => Duration(milliseconds: item as int)).toList();
    } catch (e) {
      debugPrint("Failed to get app activity: '$e'.");
      return List.filled(24, Duration.zero);
    }
  }

  Future<String?> getAppIcon(String packageName) async {
    if (kIsWeb) return null;
    try {
      final String? iconBase64 = await _channel.invokeMethod('getAppIcon', {'packageName': packageName});
      return iconBase64;
    } catch (e) {
      debugPrint("Failed to get app icon: '$e'.");
      return null;
    }
  }

  Future<int> getUnlockCount() async {
    if (kIsWeb) return 32;
    try {
      final int count = await _channel.invokeMethod('getUnlockCount');
      return count;
    } catch (e) {
      debugPrint("Failed to get unlock count: '$e'.");
      return 32;
    }
  }

  Future<SleepData?> getSleepStats() async {
    if (kIsWeb) {
      return _getWebSleepStats();
    }
    try {
      final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getSleepStats');
      if (stats == null) return _getWebSleepStats();
      
      return SleepData(
        sleepStart: DateTime.fromMillisecondsSinceEpoch(stats['sleepStart']),
        sleepEnd: DateTime.fromMillisecondsSinceEpoch(stats['sleepEnd']),
        duration: Duration(milliseconds: stats['duration']),
      );
    } catch (e) {
      debugPrint("Failed to get sleep stats: '$e'.");
      return _getWebSleepStats();
    }
  }

  Future<Map<String, dynamic>> getFocusStats() async {
    if (kIsWeb) {
      return _getWebFocusStats();
    }
    try {
      final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getFocusStats');
      if (stats == null) return _getWebFocusStats();
      return Map<String, dynamic>.from(stats);
    } catch (e) {
      debugPrint("Failed to get focus stats: '$e'.");
      return _getWebFocusStats();
    }
  }

  List<UsageData> _getWebDailyUsageStats() {
    final now = DateTime.now();
    return [
      UsageData(
        packageName: 'com.google.chrome',
        appName: 'Chrome Web Browser',
        totalTimeVisible: const Duration(hours: 2, minutes: 45),
        lastUsed: now.subtract(const Duration(minutes: 5)),
        unlockCount: 12,
      ),
      UsageData(
        packageName: 'com.microsoft.vscode',
        appName: 'VS Code Web',
        totalTimeVisible: const Duration(hours: 1, minutes: 35),
        lastUsed: now.subtract(const Duration(minutes: 30)),
        unlockCount: 8,
      ),
      UsageData(
        packageName: 'com.google.youtube',
        appName: 'YouTube Web',
        totalTimeVisible: const Duration(minutes: 50),
        lastUsed: now.subtract(const Duration(hours: 2)),
        unlockCount: 5,
      ),
      UsageData(
        packageName: 'com.figma.web',
        appName: 'Figma Workspace',
        totalTimeVisible: const Duration(minutes: 30),
        lastUsed: now.subtract(const Duration(hours: 4)),
        unlockCount: 4,
      ),
      UsageData(
        packageName: 'com.slack.web',
        appName: 'Slack Chat',
        totalTimeVisible: const Duration(minutes: 25),
        lastUsed: now.subtract(const Duration(hours: 1)),
        unlockCount: 3,
      ),
    ];
  }

  List<Duration> _getWebWeeklyUsage() {
    return const [
      Duration(hours: 4, minutes: 15),
      Duration(hours: 5, minutes: 30),
      Duration(hours: 3, minutes: 45),
      Duration(hours: 6, minutes: 10),
      Duration(hours: 4, minutes: 50),
      Duration(hours: 2, minutes: 40),
      Duration(hours: 5, minutes: 45),
    ];
  }

  SleepData _getWebSleepStats() {
    final now = DateTime.now();
    final sleepStart = DateTime(now.year, now.month, now.day - 1, 23, 15);
    final sleepEnd = DateTime(now.year, now.month, now.day, 7, 0);
    return SleepData(
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      duration: sleepEnd.difference(sleepStart),
    );
  }

  Map<String, dynamic> _getWebFocusStats() {
    return {
      'focusScore': 88,
      'interruptions': 4,
      'longestSessionMs': 45 * 60 * 1000,
    };
  }
}
