package com.sidalidev.noor

import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.gdelataillade.alarm.alarm.AlarmService
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showOverLockScreen(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        showOverLockScreen(intent)
    }

    // Only a ringing adhan may put the app over the keyguard; opening the app
    // from the launcher never does.
    private fun showOverLockScreen(intent: Intent) {
        if (intent.action != AlarmService.ACTION_RING) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) return
        setShowWhenLocked(true)
        setTurnScreenOn(true)
    }

    // Screen off ends the alarm's moment: the app must not stay on the lock screen.
    override fun onStop() {
        super.onStop()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
    }
}
