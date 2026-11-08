package com.sidalidev.noor

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.lifecycle.Observer
import com.gdelataillade.alarm.alarm.AlarmService
import com.gdelataillade.alarm.services.AlarmRingingLiveData
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "noor/app"
        const val EXTRA_TAB = "com.sidalidev.noor.TAB"
        const val TAB_ATHKAR = 2
    }

    private var channel: MethodChannel? = null

    // A tab asked for by the intent that opened the app, until Dart takes it.
    private var launchTab: Int? = null

    // Registered after super.onCreate, so it runs after the alarm plugin's own
    // observer, which puts whatever activity it is attached to over the lock
    // screen while an alarm rings. The app never goes there: AdhanActivity does.
    // Only delivered while this activity is started, that is, in use.
    private val ringing = Observer<Boolean> { isRinging ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
        if (isRinging) showRingingAdhan()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        launchTab = tabOf(intent)
        AlarmRingingLiveData.instance.observe(this, ringing)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val tab = tabOf(intent) ?: return
        launchTab = tab
        // Before the shell is up nothing handles it, and Dart pulls the tab
        // with "launchTab" once it is.
        channel?.invokeMethod("openTab", tab, object : MethodChannel.Result {
            override fun success(result: Any?) {
                launchTab = null
            }

            override fun error(code: String, message: String?, details: Any?) {}
            override fun notImplemented() {}
        })
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchTab" -> {
                        result.success(launchTab)
                        launchTab = null
                    }
                    "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent())
                    "openFullScreenIntentSettings" -> {
                        openFullScreenIntentSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun tabOf(intent: Intent?): Int? =
        intent?.takeIf { it.hasExtra(EXTRA_TAB) }?.getIntExtra(EXTRA_TAB, 0)

    /** The adhan that just started, on its own screen; the system only does it for a locked phone. */
    private fun showRingingAdhan() {
        val id = AlarmService.ringingAlarmIds.firstOrNull() ?: return
        startActivity(
            Intent(this, AdhanActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra(AlarmService.EXTRA_ALARM_ID, id)
        )
    }

    // Android 14 grants full-screen alerts only to apps the user allows; without
    // it a ringing adhan is a heads-up notification, never the adhan screen.
    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return manager.canUseFullScreenIntent()
    }

    private fun openFullScreenIntentSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        startActivity(
            Intent(
                Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                Uri.parse("package:$packageName")
            )
        )
    }
}
