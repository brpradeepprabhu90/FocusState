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

    private val quotes = listOf(
        "\"Lost time is never found again.\" - Benjamin Franklin",
        "\"Time is what we want most, but what we use worst.\" - William Penn",
        "\"The key is in not spending time, but in investing it.\" - Stephen R. Covey",
        "\"Don't be fooled by the calendar. There are only as many days in the year as you make use of.\" - Charles Richards",
        "\"Ordinary people think merely of spending time, great people think of using it.\" - Arthur Schopenhauer"
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#121212")) // Dark theme
            setPadding(64, 64, 64, 64)
        }

        val quoteTextView = TextView(this).apply {
            text = quotes.random()
            setTextColor(Color.parseColor("#818CF8")) // Indigo
            textSize = 22f
            setTypeface(null, Typeface.ITALIC)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 64)
        }
        layout.addView(quoteTextView)

        val timerTextView = TextView(this).apply {
            text = "Redirecting in 5..."
            setTextColor(Color.WHITE)
            textSize = 18f
            gravity = Gravity.CENTER
        }
        layout.addView(timerTextView)

        setContentView(layout)

        object : CountDownTimer(5000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                timerTextView.text = "Redirecting in ${millisUntilFinished / 1000}..."
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
        // Prevent back button during the 5 second penalty
    }
}
