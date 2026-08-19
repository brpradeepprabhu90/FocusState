package com.flowstate.flow_state_app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.content.ContextCompat
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
                    val packages = call.argument<List<String>>("packages")
                        ?: call.argument<List<String>>("blockedApps")
                        ?: emptyList()
                    saveAndEnableBlocking(packages)
                    result.success(true)
                }
                "stopBlocking" -> {
                    disableBlocking()
                    result.success(true)
                }
                "updateBlockedApps" -> {
                    val packages = call.argument<List<String>>("blockedApps")
                        ?: call.argument<List<String>>("packages")
                        ?: emptyList()
                    val isEnabled = call.argument<Boolean>("isEnabled") ?: true
                    if (isEnabled && packages.isNotEmpty()) {
                        saveAndEnableBlocking(packages)
                    } else if (!isEnabled) {
                        disableBlocking()
                    } else {
                        // Even if list is empty, update the stored list
                        saveAndEnableBlocking(packages)
                    }
                    result.success(true)
                }
                "openAccessibilitySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "checkAccessibilityService" -> {
                    val isServiceRunning = AppBlockerService.instance != null
                    val isSettingEnabled = isAccessibilityServiceEnabled(this)
                    result.success(isServiceRunning || isSettingEnabled)
                }
                "checkBatteryOptimization" -> {
                    try {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    } catch (e: Exception) {
                        result.success(false)
                    }
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
                "checkNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= 33) {
                        val granted = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                        result.success(granted)
                    } else {
                        result.success(true)
                    }
                }
                "openNotificationSettings" -> {
                    try {
                        val intent = Intent().apply {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            } else {
                                action = "android.settings.APP_NOTIFICATION_SETTINGS"
                                putExtra("app_package", packageName)
                                putExtra("app_uid", applicationInfo.uid)
                            }
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
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
                else -> result.notImplemented()
            }
        }
    }

    private fun saveAndEnableBlocking(packages: List<String>) {
        val prefs = getSharedPreferences("com.flowstate.app_blocker", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("is_blocking_active", true)
            .putStringSet("blocked_packages", packages.toSet())
            .apply()
        AppBlockerService.isBlockingActive = true
        AppBlockerService.blockedPackages = packages.toSet()
    }

    private fun disableBlocking() {
        val prefs = getSharedPreferences("com.flowstate.app_blocker", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("is_blocking_active", false).apply()
        AppBlockerService.isBlockingActive = false
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val expectedServiceName = "${context.packageName}/${AppBlockerService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return enabledServices.contains(expectedServiceName) || enabledServices.contains(AppBlockerService::class.java.canonicalName ?: "")
    }

    override fun onDestroy() {
        super.onDestroy()
        // Do NOT disable blocking on activity destroy so focus mode persists when app is swiped away
    }
}
