package com.flowstate.flow_state_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class AppBlockerService : AccessibilityService() {

    companion object {
        var isBlockingActive: Boolean = false
        var blockedPackages: Set<String> = emptySet()
        var instance: AppBlockerService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isBlockingActive || event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            // Don't block our own app
            if (packageName == applicationContext.packageName) return

            if (blockedPackages.contains(packageName)) {
                // Redirect to InterceptActivity instead of FlowState directly
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
