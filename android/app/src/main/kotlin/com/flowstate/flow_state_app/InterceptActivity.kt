package com.flowstate.flow_state_app

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.os.CountDownTimer
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView

class InterceptActivity : Activity() {

    private val mindfulPrompts = listOf(
        "Take a deep breath 🌬️\nAre you choosing to scroll right now?",
        "Mindful Speed Bump 🧘\nPause for a second before continuing.",
        "Reflect & Re-center 🧠\nIs this task helping your focus today?",
        "Breathe in... Breathe out 🌸\nIntention over subconscious habit."
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0F172A")) // Calming slate dark theme
            setPadding(64, 64, 64, 64)
        }

        val promptTextView = TextView(this).apply {
            text = mindfulPrompts.random()
            setTextColor(Color.parseColor("#818CF8")) // Indigo soft
            textSize = 22f
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }
        layout.addView(promptTextView)

        val timerTextView = TextView(this).apply {
            text = "Mindful Pause: 5s remaining..."
            setTextColor(Color.WHITE)
            textSize = 16f
            gravity = Gravity.CENTER
        }
        layout.addView(timerTextView)

        setContentView(layout)

        object : CountDownTimer(5000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                val seconds = (millisUntilFinished / 1000) + 1
                timerTextView.text = "Mindful Pause: ${seconds}s remaining..."
            }

            override fun onFinish() {
                if (!isFinishing) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(applicationContext.packageName)
                    if (launchIntent != null) {
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        startActivity(launchIntent)
                    }
                    finish()
                }
            }
        }.start()
    }
    
    override fun onBackPressed() {
        // Prevent back button bypass during mindful pause
    }
}
