package com.driftmind.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.driftmind.app/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val helper = UsageStatsHelper(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(helper.hasPermission())
                "openSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "getTotalScreenTime" -> {
                    val cal = java.util.Calendar.getInstance()
                    cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
                    cal.set(java.util.Calendar.MINUTE, 0)
                    cal.set(java.util.Calendar.SECOND, 0)
                    cal.set(java.util.Calendar.MILLISECOND, 0)
                    val todayStart = cal.timeInMillis
                    val startTime = call.argument<Long>("startTime") ?: todayStart
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                    result.success(helper.getTotalScreenTime(startTime, endTime))
                }
                "getDailyUsageStats" -> result.success(helper.getDailyUsageStats())
                "getWeeklyUsage" -> result.success(helper.getWeeklyUsage())
                "getAppActivity" -> result.success(helper.getAppActivity(call.argument<String>("packageName") ?: ""))
                "getAppIcon" -> result.success(helper.getAppIcon(call.argument<String>("packageName") ?: ""))
                "getUnlockCount" -> result.success(helper.getUnlockCount())
                "getSleepStats" -> result.success(helper.getSleepStats())
                "getFocusStats" -> result.success(helper.getFocusStats())
                else -> result.notImplemented()
            }
        }
    }
}
