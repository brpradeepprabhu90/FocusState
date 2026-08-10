package com.flowstate.flow_state_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.flowstate/app_blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBlocking" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    AppBlockerService.isBlockingActive = true
                    AppBlockerService.blockedPackages = packages.toSet()
                    result.success(true)
                }
                "stopBlocking" -> {
                    AppBlockerService.isBlockingActive = false
                    result.success(true)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "checkAccessibilityService" -> {
                    result.success(AppBlockerService.instance != null)
                }
                "getInstalledApps" -> {
                    val pm = packageManager
                    val mainIntent = Intent(Intent.ACTION_MAIN, null)
                    mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
                    val resolvedInfos = pm.queryIntentActivities(mainIntent, 0)
                    
                    val resultList = resolvedInfos.map { resolveInfo ->
                        mapOf(
                            "name" to resolveInfo.loadLabel(pm).toString(),
                            "packageName" to resolveInfo.activityInfo.packageName
                        )
                    }.distinctBy { it["packageName"] }.sortedBy { it["name"] as String }
                    
                    result.success(resultList)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
