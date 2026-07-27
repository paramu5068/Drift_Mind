package com.driftmind.app

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream
import java.util.*

class UsageStatsHelper(private val context: Context) {

    fun hasPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = appOps.checkOpNoThrow(
            android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }

    fun getTotalScreenTime(startTime: Long, endTime: Long): Long {
        val stats = getDailyUsageStatsForRange(startTime, endTime)
        return stats.sumOf { it["totalTimeVisible"] as Long }
    }

    private fun getDailyUsageStatsForRange(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val queryStart = startTime - (12 * 60 * 60 * 1000L)
        val prepEvents = usageStatsManager.queryEvents(queryStart, startTime)
        val event = UsageEvents.Event()
        
        var activePkgAtStart: String? = null
        var isScreenOnAtStart = false
        
        while (prepEvents.hasNextEvent()) {
            prepEvents.getNextEvent(event)
            when (event.eventType) {
                1 -> activePkgAtStart = event.packageName
                2 -> if (activePkgAtStart == event.packageName) activePkgAtStart = null
                15 -> isScreenOnAtStart = true
                16 -> isScreenOnAtStart = false
            }
        }

        val events = usageStatsManager.queryEvents(startTime, endTime)
        val appDurations = mutableMapOf<String, Long>()
        val lastForegroundTime = mutableMapOf<String, Long>()
        var currentScreenOn = isScreenOnAtStart

        if (currentScreenOn && activePkgAtStart != null) {
            lastForegroundTime[activePkgAtStart] = startTime
        }

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName
            val ts = event.timeStamp

            when (event.eventType) {
                15 -> { 
                    currentScreenOn = true
                    if (activePkgAtStart != null) lastForegroundTime[activePkgAtStart] = ts
                }
                16 -> {
                    if (currentScreenOn) {
                        for ((p, start) in lastForegroundTime) {
                            appDurations[p] = (appDurations[p] ?: 0L) + (ts - start)
                        }
                        lastForegroundTime.clear()
                    }
                    currentScreenOn = false
                }
                1 -> {
                    if (currentScreenOn) {
                        for ((p, start) in lastForegroundTime) {
                            appDurations[p] = (appDurations[p] ?: 0L) + (ts - start)
                        }
                        lastForegroundTime.clear()
                        lastForegroundTime[pkg] = ts
                    }
                    activePkgAtStart = pkg
                }
                2 -> {
                    val start = lastForegroundTime[pkg]
                    if (start != null) {
                        appDurations[pkg] = (appDurations[pkg] ?: 0L) + (ts - start)
                        lastForegroundTime.remove(pkg)
                    }
                    if (activePkgAtStart == pkg) activePkgAtStart = null
                }
            }
        }

        if (currentScreenOn) {
            for ((p, start) in lastForegroundTime) {
                appDurations[p] = (appDurations[p] ?: 0L) + (endTime - start)
            }
        }

        val result = mutableListOf<Map<String, Any>>()
        val pm = context.packageManager
        for ((packageName, totalTime) in appDurations) {
            if (totalTime > 1000) {
                val appInfo = try { pm.getApplicationInfo(packageName, 0) } catch (e: Exception) { null }
                val appName = appInfo?.let { pm.getApplicationLabel(it).toString() } ?: packageName
                if (appName != packageName || pm.getLaunchIntentForPackage(packageName) != null || totalTime > 30_000L) {
                    result.add(mapOf("appName" to appName, "packageName" to packageName, "totalTimeVisible" to totalTime))
                }
            }
        }
        return result.sortedByDescending { it["totalTimeVisible"] as Long }
    }

    fun getWeeklyUsage(): List<Long> {
        val result = mutableListOf<Long>()
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val todayStart = calendar.timeInMillis
        for (i in 6 downTo 0) {
            val dayStart = todayStart - (i * 24 * 60 * 60 * 1000L)
            val dayEnd = dayStart + (24 * 60 * 60 * 1000L)
            result.add(getTotalScreenTime(dayStart, minOf(dayEnd, System.currentTimeMillis())))
        }
        return result
    }

    fun getDailyUsageStats(): List<Map<String, Any>> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return getDailyUsageStatsForRange(calendar.timeInMillis, System.currentTimeMillis())
    }

    fun getAppActivity(packageName: String): List<Long> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(startTime, endTime)
        val hourlyActivity = LongArray(24) { 0L }
        val event = UsageEvents.Event()
        var lastForegroundTime = 0L

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.packageName == packageName) {
                if (event.eventType == 1) lastForegroundTime = event.timeStamp
                else if (event.eventType == 2 && lastForegroundTime != 0L) {
                    distributeHourly(lastForegroundTime, event.timeStamp, startTime, hourlyActivity)
                    lastForegroundTime = 0L
                }
            }
        }
        if (lastForegroundTime != 0L) distributeHourly(lastForegroundTime, endTime, startTime, hourlyActivity)
        return hourlyActivity.toList()
    }

    private fun distributeHourly(sessionStart: Long, sessionEnd: Long, dayStart: Long, hourlyActivity: LongArray) {
        var current = sessionStart
        while (current < sessionEnd) {
            val hourIndex = ((current - dayStart) / (60 * 60 * 1000L)).toInt()
            if (hourIndex in 0..23) {
                val nextHourBoundary = dayStart + ((hourIndex + 1) * 60 * 60 * 1000L)
                val segmentEnd = minOf(sessionEnd, nextHourBoundary)
                hourlyActivity[hourIndex] += (segmentEnd - current)
                current = segmentEnd
            } else break
        }
    }

    fun getUnlockCount(): Int {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        val startTime = calendar.timeInMillis
        val events = usageStatsManager.queryEvents(startTime, System.currentTimeMillis())
        var unlocks = 0
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == 18) unlocks++
        }
        return unlocks
    }

    /**
     * Refined Sleep Logic: Detects the longest nighttime gap between 9 PM and 11 AM.
     */
    fun getSleepStats(): Map<String, Any>? {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        val cal = Calendar.getInstance()
        cal.add(Calendar.DAY_OF_YEAR, -1)
        cal.set(Calendar.HOUR_OF_DAY, 21) // 9 PM
        cal.set(Calendar.MINUTE, 0)
        val startScan = cal.timeInMillis
        
        val calEnd = Calendar.getInstance()
        calEnd.set(Calendar.HOUR_OF_DAY, 11) // 11 AM
        calEnd.set(Calendar.MINUTE, 0)
        val endScan = minOf(System.currentTimeMillis(), calEnd.timeInMillis)

        val events = usageStatsManager.queryEvents(startScan, endScan)
        val event = UsageEvents.Event()
        
        var maxGap = 0L
        var sleepStart = 0L
        var sleepEnd = 0L
        var lastActivity = startScan

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == 1 || event.eventType == 15 || event.eventType == 18) {
                val gap = event.timeStamp - lastActivity
                // Prioritize gaps that are late at night
                if (gap > maxGap) {
                    maxGap = gap
                    sleepStart = lastActivity
                    sleepEnd = event.timeStamp
                }
                lastActivity = event.timeStamp
            }
        }
        
        val finalGap = endScan - lastActivity
        if (finalGap > maxGap) {
            maxGap = finalGap
            sleepStart = lastActivity
            sleepEnd = endScan
        }

        if (maxGap < 4 * 60 * 60 * 1000L) return null

        return mapOf(
            "sleepStart" to sleepStart,
            "sleepEnd" to sleepEnd,
            "duration" to maxGap
        )
    }

    /**
     * Focus Logic: Analyze switches and session length in the last 2 hours.
     */
    fun getFocusStats(): Map<String, Any> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - (2 * 60 * 60 * 1000L) // Last 2 hours

        val events = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()
        
        var switches = 0
        var longestSession = 0L
        var currentSessionStart = 0L
        var lastPkg = ""
        
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == 1) { // MOVE_TO_FOREGROUND
                if (event.packageName != lastPkg) {
                    if (lastPkg.isNotEmpty()) {
                        val sessionDuration = event.timeStamp - currentSessionStart
                        if (sessionDuration > longestSession && !isSystemApp(lastPkg)) {
                            longestSession = sessionDuration
                        }
                        switches++
                    }
                    currentSessionStart = event.timeStamp
                    lastPkg = event.packageName
                }
            }
        }
        
        // Check final session
        if (lastPkg.isNotEmpty()) {
            val finalSession = endTime - currentSessionStart
            if (finalSession > longestSession && !isSystemApp(lastPkg)) longestSession = finalSession
        }

        val focusScore = (100 - (switches * 5)).coerceIn(0, 100)

        return mapOf(
            "focusScore" to focusScore,
            "interruptions" to switches,
            "longestSessionMs" to longestSession
        )
    }

    private fun isSystemApp(pkg: String): Boolean {
        return pkg.contains("launcher") || pkg.contains("systemui") || pkg.contains("settings")
    }

    fun getAppIcon(packageName: String): String? {
        val pm = context.packageManager
        return try {
            val icon = pm.getApplicationIcon(packageName)
            val bitmap = Bitmap.createBitmap(icon.intrinsicWidth.coerceAtLeast(1), icon.intrinsicHeight.coerceAtLeast(1), Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            icon.setBounds(0, 0, canvas.width, canvas.height)
            icon.draw(canvas)
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
        } catch (e: Exception) { null }
    }
}
