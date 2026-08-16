package com.flowstate.flow_state_app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class AppBlockerService : AccessibilityService() {

    companion object {
        var isBlockingActive: Boolean = false
        var blockedPackages: Set<String> = emptySet()
        var instance: AppBlockerService? = null
        private var lastBlockedTime = 0L
        private var lastBlockedPackage = ""
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        // Read active status from SharedPreferences or companion variable
        val prefs = applicationContext.getSharedPreferences("com.flowstate.app_blocker", Context.MODE_PRIVATE)
        val active = isBlockingActive || prefs.getBoolean("is_blocking_active", false)
        if (!active) return

        val packages = if (blockedPackages.isNotEmpty()) blockedPackages else (prefs.getStringSet("blocked_packages", emptySet()) ?: emptySet())
        if (packages.isEmpty()) return

        val eventType = event.eventType
        if (eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED || eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            // Ignore our own app, InterceptActivity, Android system UI, and launchers
            if (packageName == applicationContext.packageName) return
            if (packageName.contains("launcher") || packageName.contains("systemui")) return

            if (packages.contains(packageName)) {
                val currentTime = System.currentTimeMillis()
                // Throttle repeated triggers within 1.5 seconds for the same app
                if (packageName == lastBlockedPackage && currentTime - lastBlockedTime < 1500) {
                    return
                }
                lastBlockedTime = currentTime
                lastBlockedPackage = packageName

                // Redirect to InterceptActivity
                val intent = Intent(this, InterceptActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                startActivity(intent)

                Toast.makeText(
                    applicationContext,
                    "🚫 Focus Mode Active!",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}
