import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/usage_data.dart';
import '../../models/wellness_data.dart';

class UsageService {
  static const _channel = MethodChannel('com.driftmind.app/usage_stats');

  Future<bool> hasPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint("Failed to check permission: '${e.message}'.");
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open settings: '${e.message}'.");
    }
  }

  Future<List<UsageData>> getDailyUsageStats() async {
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getDailyUsageStats');
      if (stats == null) return [];
      return stats.map((item) => UsageData.fromMap(item as Map)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get usage stats: '${e.message}'.");
      return [];
    }
  }

  Future<Duration> getTotalScreenTime() async {
    try {
      final int ms = await _channel.invokeMethod('getTotalScreenTime');
      return Duration(milliseconds: ms);
    } on PlatformException catch (e) {
      debugPrint("Failed to get total screen time: '${e.message}'.");
      return Duration.zero;
    }
  }

  Future<List<Duration>> getWeeklyUsage() async {
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getWeeklyUsage');
      if (stats == null) return [];
      return stats.map((item) => Duration(milliseconds: item as int)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get weekly usage: '${e.message}'.");
      return [];
    }
  }

  Future<List<Duration>> getAppActivity(String packageName) async {
    try {
      final List<dynamic>? stats = await _channel.invokeMethod('getAppActivity', {'packageName': packageName});
      if (stats == null) return List.filled(24, Duration.zero);
      return stats.map((item) => Duration(milliseconds: item as int)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get app activity: '${e.message}'.");
      return List.filled(24, Duration.zero);
    }
  }

  Future<String?> getAppIcon(String packageName) async {
    try {
      final String? iconBase64 = await _channel.invokeMethod('getAppIcon', {'packageName': packageName});
      return iconBase64;
    } on PlatformException catch (e) {
      debugPrint("Failed to get app icon: '${e.message}'.");
      return null;
    }
  }

  Future<int> getUnlockCount() async {
    try {
      final int count = await _channel.invokeMethod('getUnlockCount');
      return count;
    } on PlatformException catch (e) {
      debugPrint("Failed to get unlock count: '${e.message}'.");
      return 0;
    }
  }

  Future<SleepData?> getSleepStats() async {
    try {
      final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getSleepStats');
      if (stats == null) return null;
      
      return SleepData(
        sleepStart: DateTime.fromMillisecondsSinceEpoch(stats['sleepStart']),
        sleepEnd: DateTime.fromMillisecondsSinceEpoch(stats['sleepEnd']),
        duration: Duration(milliseconds: stats['duration']),
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to get sleep stats: '${e.message}'.");
      return null;
    }
  }

  Future<Map<String, dynamic>> getFocusStats() async {
    try {
      final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getFocusStats');
      if (stats == null) return {'focusScore': 100, 'interruptions': 0, 'longestSessionMs': 0};
      return Map<String, dynamic>.from(stats);
    } on PlatformException catch (e) {
      debugPrint("Failed to get focus stats: '${e.message}'.");
      return {'focusScore': 100, 'interruptions': 0, 'longestSessionMs': 0};
    }
  }
}
