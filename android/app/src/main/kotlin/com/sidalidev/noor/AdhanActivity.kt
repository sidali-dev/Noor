package com.sidalidev.noor

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.lifecycle.Observer
import com.gdelataillade.alarm.alarm.AlarmReceiver
import com.gdelataillade.alarm.alarm.AlarmService
import com.gdelataillade.alarm.services.AlarmRingingLiveData
import com.github.dart_lang.jni.JniPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin

/**
 * The ringing adhan, alone in its own task and over the lock screen, the way a
 * clock app shows an alarm. The alarm plugin opens it (its `ACTION_RING`), and
 * [MainActivity] opens it when an adhan starts while the app is in use.
 *
 * It runs the Dart `adhanMain` entrypoint straight to the ring screen, and
 * finishes, task and all, as soon as the adhan stops, whichever way it stops:
 * its own buttons, the notification's Stop, or the recitation ending.
 */
class AdhanActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "noor/adhan"

        // An activity opened for an adhan that never reports ringing (it was
        // stopped while this started) closes after this long.
        private const val NOT_RINGING_GRACE_MS = 4_000L
    }

    private var channel: MethodChannel? = null
    private val handler = Handler(Looper.getMainLooper())
    private var seenRinging = false

    private val ringing = Observer<Boolean> { isRinging ->
        if (isRinging) seenRinging = true else if (seenRinging) close()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        showOverLockScreen()
        // Until Flutter's first frame the window shows; in the app's theme, not
        // the system's, so neither theme flashes black or white.
        window.setBackgroundDrawable(ColorDrawable(groundColor()))
        super.onCreate(savedInstanceState)
        // Forever, not lifecycle-bound: a stop while the screen is off must
        // still end this task.
        AlarmRingingLiveData.instance.observeForever(ringing)
        handler.postDelayed({ if (!seenRinging) close() }, NOT_RINGING_GRACE_MS)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        channel?.invokeMethod("alarm", alarmOf(intent))
    }

    override fun onDestroy() {
        AlarmRingingLiveData.instance.removeObserver(ringing)
        handler.removeCallbacksAndMessages(null)
        channel?.setMethodCallHandler(null)
        super.onDestroy()
    }

    override fun getDartEntrypointFunctionName() = "adhanMain"

    override fun shouldHandleDeeplinking() = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Not super, which registers every plugin: the alarm plugin keeps one
        // process-wide callback to Dart, and taking it here would leave the
        // app's own engine deaf to alarms once this one is gone. shared_preferences
        // reaches Java through package:jni, which crashes the process unless
        // its plugin has set JNI up first, as it has not in a cold start.
        flutterEngine.plugins.add(JniPlugin())
        flutterEngine.plugins.add(SharedPreferencesPlugin())
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "alarm" -> result.success(alarmOf(intent))
                    "stop" -> {
                        stopAdhan()
                        close()
                        result.success(null)
                    }
                    "openAthkar" -> {
                        openAthkar()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun alarmOf(intent: Intent?): Map<String, Any?> = mapOf(
        "id" to (intent?.getIntExtra(AlarmService.EXTRA_ALARM_ID, 0) ?: 0),
        "title" to intent?.getStringExtra(AlarmService.EXTRA_ALARM_TITLE),
        "body" to intent?.getStringExtra(AlarmService.EXTRA_ALARM_BODY),
    )

    private fun showOverLockScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun groundColor(): Int {
        val dark = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean("flutter.isDarkTheme", false)
        return if (dark) 0xFF101217.toInt() else 0xFFEEF0F4.toInt()
    }

    /**
     * Stops the adhan the way the notification's Stop does. Straight on the
     * service when it runs, so the audio is off before [MainActivity] can start
     * and take the adhan for one still ringing.
     */
    private fun stopAdhan() {
        val id = intent?.getIntExtra(AlarmService.EXTRA_ALARM_ID, 0) ?: 0
        val ids = if (id != 0) listOf(id) else AlarmService.ringingAlarmIds
        for (alarmId in ids) {
            val service = AlarmService.instance
            if (service != null) {
                service.handleStopAlarmCommand(alarmId)
            } else {
                sendBroadcast(
                    Intent(this, AlarmReceiver::class.java)
                        .setAction(AlarmReceiver.ACTION_ALARM_STOP)
                        .putExtra("id", alarmId)
                )
            }
        }
    }

    /** The app on its Athkar tab, once the phone is unlocked. */
    private fun openAthkar() {
        // The stop below must not close this activity: the keyguard dismissal
        // reports back to it, and only then does the app start.
        AlarmRingingLiveData.instance.removeObserver(ringing)
        handler.removeCallbacksAndMessages(null)
        stopAdhan()
        val launch = Intent(this, MainActivity::class.java)
            .addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            .putExtra(MainActivity.EXTRA_TAB, MainActivity.TAB_ATHKAR)
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && keyguard.isKeyguardLocked) {
            keyguard.requestDismissKeyguard(this, object : KeyguardManager.KeyguardDismissCallback() {
                override fun onDismissSucceeded() {
                    startActivity(launch)
                    close()
                }

                override fun onDismissCancelled() = close()

                override fun onDismissError() = close()
            })
        } else {
            startActivity(launch)
            close()
        }
    }

    private fun close() {
        if (isFinishing) return
        finishAndRemoveTask()
    }
}
