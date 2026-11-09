package com.sidalidev.noor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.graphics.drawable.Icon
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.provider.Settings
import androidx.lifecycle.Observer
import com.gdelataillade.alarm.alarm.AlarmService
import com.gdelataillade.alarm.services.AlarmRingingLiveData
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.cos
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "noor/app"
        const val EXTRA_TAB = "com.sidalidev.noor.TAB"
        const val TAB_QURAN = 0
        const val TAB_ATHKAR = 2

        private const val MEDIA_CHANNEL_ID = "noor_quran_media_session"
        private const val MEDIA_NOTIFICATION_ID = 4401
        private const val ACTION_MEDIA_CONTROL = "com.sidalidev.noor.QURAN_MEDIA_CONTROL"
        private const val EXTRA_MEDIA_CMD = "cmd"
    }

    private var channel: MethodChannel? = null
    private var mediaReceiverRegistered = false
    private var mediaSession: MediaSession? = null
    private var templateBaseBitmap: Bitmap? = null
    private var amiriBoldTypeface: Typeface? = null
    private var cormorantTypeface: Typeface? = null
    private var cachedArtSurah: Int = -1
    private var cachedArtBitmap: Bitmap? = null

    // A tab asked for by the intent that opened the app, until Dart takes it.
    private var launchTab: Int? = null

    private val mediaControlReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action != ACTION_MEDIA_CONTROL) return
            val cmd = intent.getStringExtra(EXTRA_MEDIA_CMD) ?: return
            channel?.invokeMethod("mediaAction", cmd)
        }
    }

    // Registered after super.onCreate, so it runs after the alarm plugin's own
    // observer, which puts whatever activity it is attached to over the lock
    // screen while an alarm rings. The app never goes there: AdhanActivity does.
    // Only delivered while this activity is started, that is, in use.
    private val ringing = Observer<Boolean> { isRinging ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
        if (isRinging) {
            channel?.invokeMethod("mediaAction", "pause")
            showRingingAdhan()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        launchTab = tabOf(intent)
        AlarmRingingLiveData.instance.observe(this, ringing)
        registerMediaReceiver()
    }

    override fun onDestroy() {
        unregisterMediaReceiver()
        cancelMediaNotification()
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }

    private fun ensureMediaSession(): MediaSession {
        mediaSession?.let { return it }
        val session = MediaSession(this, "NoorQuranMediaSession").apply {
            setCallback(object : MediaSession.Callback() {
                override fun onPlay() {
                    channel?.invokeMethod("mediaAction", "play")
                }

                override fun onPause() {
                    channel?.invokeMethod("mediaAction", "pause")
                }

                override fun onSkipToPrevious() {
                    channel?.invokeMethod("mediaAction", "rewind")
                }

                override fun onSkipToNext() {
                    channel?.invokeMethod("mediaAction", "fast_forward")
                }

                override fun onRewind() {
                    channel?.invokeMethod("mediaAction", "rewind")
                }

                override fun onFastForward() {
                    channel?.invokeMethod("mediaAction", "fast_forward")
                }

                override fun onStop() {
                    channel?.invokeMethod("mediaAction", "stop")
                }

                override fun onSeekTo(pos: Long) {
                    channel?.invokeMethod("mediaSeekTo", pos)
                }

                override fun onCustomAction(action: String, extras: Bundle?) {
                    channel?.invokeMethod("mediaAction", action)
                }
            })
            isActive = true
        }
        mediaSession = session
        return session
    }

    private fun registerMediaReceiver() {
        if (mediaReceiverRegistered) return
        val filter = IntentFilter(ACTION_MEDIA_CONTROL)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(mediaControlReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(mediaControlReceiver, filter)
        }
        mediaReceiverRegistered = true
    }

    private fun unregisterMediaReceiver() {
        if (!mediaReceiverRegistered) return
        try {
            unregisterReceiver(mediaControlReceiver)
        } catch (_: Exception) {}
        mediaReceiverRegistered = false
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
                    "updateMediaNotification" -> {
                        val args = call.arguments as? Map<*, *>
                        val surahNumber = (args?.get("surahNumber") as? Number)?.toInt() ?: 1
                        val surahAr = args?.get("surahAr") as? String ?: "الفاتحة"
                        val surahEn = args?.get("surahEn") as? String ?: "Al-Fatihah"
                        val title = args?.get("title") as? String ?: "سورة $surahAr"
                        val subtitle = args?.get("subtitle") as? String ?: ""
                        val isPlaying = args?.get("isPlaying") as? Boolean ?: false
                        val positionMs = (args?.get("positionMs") as? Number)?.toLong() ?: 0L
                        val durationMs = (args?.get("durationMs") as? Number)?.toLong() ?: 0L
                        val playMode = args?.get("playMode") as? String ?: "continuous"
                        showMediaNotification(
                            surahNumber = surahNumber,
                            surahAr = surahAr,
                            surahEn = surahEn,
                            title = title,
                            subtitle = subtitle,
                            isPlaying = isPlaying,
                            positionMs = positionMs,
                            durationMs = durationMs,
                            playMode = playMode
                        )
                        result.success(null)
                    }
                    "cancelMediaNotification" -> {
                        cancelMediaNotification()
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

    private fun ensureMediaChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val existing = manager.getNotificationChannel(MEDIA_CHANNEL_ID)
            if (existing == null) {
                val chan = NotificationChannel(
                    MEDIA_CHANNEL_ID,
                    "Quran Audio Player",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Media player controls for Quran recitation"
                    setShowBadge(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                manager.createNotificationChannel(chan)
            }
        }
    }

    private fun ensureTypefaces() {
        if (amiriBoldTypeface == null) {
            amiriBoldTypeface = runCatching {
                val key = FlutterInjector.instance().flutterLoader()
                    .getLookupKeyForAsset("assets/fonts/amiri/Amiri-Bold.ttf")
                Typeface.createFromAsset(assets, key)
            }.getOrNull() ?: Typeface.create(Typeface.SERIF, Typeface.BOLD)
        }
        if (cormorantTypeface == null) {
            cormorantTypeface = runCatching {
                val key = FlutterInjector.instance().flutterLoader()
                    .getLookupKeyForAsset("assets/fonts/cormorant/CormorantGaramond-SemiBold.ttf")
                Typeface.createFromAsset(assets, key)
            }.getOrNull() ?: Typeface.create(Typeface.SERIF, Typeface.NORMAL)
        }
    }

    /**
     * Builds and caches the reusable 512x512 Hilal cover template:
     * - Deep Hilal Night background (`#14171E` -> `#1E222B`) with warm radial brass glow
     * - Mushaf double-ruled brass frame (`#7A6436` / `#C7A96B`) + 4 corner Khatam stars
     * - Bundled 3D cut-paper Islamic rosette (`assets/images/art/motif_ornament_night.webp`)
     * - Inner medallion brass rings, top 4-point Hilal star, `"سُورَةُ"` header, and lower diamond rule.
     */
    private fun getOrBuildTemplateBase(): Bitmap {
        templateBaseBitmap?.let { return it }
        ensureTypefaces()

        val size = 512
        val cx = size / 2f
        val cy = size / 2f
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        // 1. Deep Hilal Night sky ground
        paint.shader = LinearGradient(
            0f, 0f, size.toFloat(), size.toFloat(),
            Color.parseColor("#13161D"),
            Color.parseColor("#222630"),
            Shader.TileMode.CLAMP
        )
        canvas.drawRect(0f, 0f, size.toFloat(), size.toFloat(), paint)

        // Soft warm radial brass glow behind the medallion
        paint.shader = RadialGradient(
            cx, cy, 220f,
            Color.parseColor("#2EB69856"),
            Color.parseColor("#0013161D"),
            Shader.TileMode.CLAMP
        )
        canvas.drawCircle(cx, cy, 220f, paint)
        paint.shader = null

        // 2. Outer and inner Mushaf brass frame rules
        paint.style = Paint.Style.STROKE
        paint.color = Color.parseColor("#8A7240")
        paint.strokeWidth = 3.5f
        canvas.drawRoundRect(RectF(20f, 20f, size - 20f, size - 20f), 28f, 28f, paint)

        paint.color = Color.parseColor("#55C7A96B")
        paint.strokeWidth = 1.6f
        canvas.drawRoundRect(RectF(32f, 32f, size - 32f, size - 32f), 20f, 20f, paint)

        // 3. Four corner Khatam 8-point stars (matching assets/images/ornaments/page_corner.svg)
        val corners = arrayOf(
            52f to 52f,
            (size - 52f) to 52f,
            52f to (size - 52f),
            (size - 52f) to (size - 52f)
        )
        paint.color = Color.parseColor("#99C7A96B")
        paint.strokeWidth = 1.8f
        for ((kx, ky) in corners) {
            val half = 9f
            canvas.save()
            canvas.translate(kx, ky)
            canvas.drawRect(-half, -half, half, half, paint)
            canvas.rotate(45f)
            canvas.drawRect(-half, -half, half, half, paint)
            canvas.restore()
        }

        // 4. Composite the bundled 3D cut-paper rosette medallion (motif_ornament_night.webp)
        val ornament = runCatching {
            val key = FlutterInjector.instance().flutterLoader()
                .getLookupKeyForAsset("assets/images/art/motif_ornament_night.webp")
            assets.open(key).use { stream -> BitmapFactory.decodeStream(stream) }
        }.getOrNull()

        if (ornament != null) {
            val dst = RectF(34f, 34f, size - 34f, size - 34f)
            canvas.drawBitmap(ornament, null, dst, Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG))
        }

        // 5. Inner circular medallion brass rings
        paint.style = Paint.Style.STROKE
        paint.color = Color.parseColor("#88C7A96B")
        paint.strokeWidth = 2.2f
        canvas.drawCircle(cx, cy, 118f, paint)

        paint.color = Color.parseColor("#40C7A96B")
        paint.strokeWidth = 1.2f
        canvas.drawCircle(cx, cy, 111f, paint)

        // 6. Top 4-point Hilal star + "سُورَةُ" header inside the medallion well
        val starY = cy - 86f
        val starR = 7f
        val starPath = Path().apply {
            moveTo(cx, starY - starR)
            quadTo(cx, starY, cx + starR, starY)
            quadTo(cx, starY, cx, starY + starR)
            quadTo(cx, starY, cx - starR, starY)
            quadTo(cx, starY, cx, starY - starR)
            close()
        }
        paint.style = Paint.Style.FILL
        paint.color = Color.parseColor("#D5B97B")
        canvas.drawPath(starPath, paint)

        paint.typeface = amiriBoldTypeface
        paint.textAlign = Paint.Align.CENTER
        paint.textSize = 22f
        paint.color = Color.parseColor("#C7A96B")
        canvas.drawText("سُورَةُ", cx, cy - 52f, paint)

        // 7. Lower ornamental brass divider (── ◆ ──)
        val divY = cy + 38f
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 1.5f
        paint.color = Color.parseColor("#77C7A96B")
        canvas.drawLine(cx - 64f, divY, cx - 12f, divY, paint)
        canvas.drawLine(cx + 12f, divY, cx + 64f, divY, paint)

        val diamond = Path().apply {
            moveTo(cx, divY - 4.5f)
            lineTo(cx + 4.5f, divY)
            lineTo(cx, divY + 4.5f)
            lineTo(cx - 4.5f, divY)
            close()
        }
        paint.style = Paint.Style.FILL
        paint.color = Color.parseColor("#C7A96B")
        canvas.drawPath(diamond, paint)

        templateBaseBitmap = bmp
        return bmp
    }

    /**
     * Combines the reusable Hilal template base with the current Surah's Arabic
     * calligraphy, Latin name, and Surah number for the native media player cover.
     */
    private fun getOrBuildHilalArtwork(
        surahNumber: Int,
        surahAr: String,
        surahEn: String
    ): Bitmap {
        if (cachedArtSurah == surahNumber && cachedArtBitmap != null) {
            return cachedArtBitmap!!
        }
        ensureTypefaces()
        val base = getOrBuildTemplateBase()
        val bmp = base.copy(Bitmap.Config.ARGB_8888, true)
        val canvas = Canvas(bmp)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val cx = bmp.width / 2f
        val cy = bmp.height / 2f

        // Arabic Surah name in Moon-White using bundled Amiri-Bold calligraphy font
        paint.style = Paint.Style.FILL
        paint.color = Color.parseColor("#F7F7F4")
        paint.textAlign = Paint.Align.CENTER
        paint.typeface = amiriBoldTypeface
        paint.setShadowLayer(8f, 0f, 3f, Color.parseColor("#88000000"))

        var arSize = 58f
        paint.textSize = arSize
        val maxArWidth = 196f
        while (paint.measureText(surahAr) > maxArWidth && arSize > 32f) {
            arSize -= 2f
            paint.textSize = arSize
        }
        canvas.drawText(surahAr, cx, cy + 8f, paint)
        paint.clearShadowLayer()

        // Surah number & Latin name in warm brass using bundled Cormorant Garamond
        paint.typeface = cormorantTypeface
        paint.color = Color.parseColor("#D5B97B")
        val metaText = "$surahNumber · $surahEn"
        var metaSize = 23f
        paint.textSize = metaSize
        while (paint.measureText(metaText) > 180f && metaSize > 16f) {
            metaSize -= 1f
            paint.textSize = metaSize
        }
        canvas.drawText(metaText, cx, cy + 72f, paint)

        cachedArtSurah = surahNumber
        cachedArtBitmap = bmp
        return bmp
    }

    private fun mediaActionPendingIntent(cmd: String, reqCode: Int): PendingIntent {
        val intent = Intent(ACTION_MEDIA_CONTROL).apply {
            setPackage(packageName)
            putExtra(EXTRA_MEDIA_CMD, cmd)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        return PendingIntent.getBroadcast(this, reqCode, intent, flags)
    }

    private fun showMediaNotification(
        surahNumber: Int,
        surahAr: String,
        surahEn: String,
        title: String,
        subtitle: String,
        isPlaying: Boolean,
        positionMs: Long,
        durationMs: Long,
        playMode: String
    ) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        ensureMediaChannel(manager)
        val session = ensureMediaSession()
        session.isActive = true

        val artBitmap = getOrBuildHilalArtwork(surahNumber, surahAr, surahEn)

        val (modeLabel, modeIconRes) = when (playMode) {
            "loop" -> "تكرار" to android.R.drawable.ic_menu_rotate
            "stopAtEnd" -> "يتوقف" to android.R.drawable.ic_menu_close_clear_cancel
            else -> "متواصل" to android.R.drawable.ic_popup_sync
        }

        val fullSubtitle = if (subtitle.isNotEmpty()) "$subtitle · $modeLabel" else modeLabel

        // Update MediaSession metadata (drives the OS Media Player card + progress bar + album art)
        val metaBuilder = MediaMetadata.Builder()
            .putString(MediaMetadata.METADATA_KEY_TITLE, title)
            .putString(MediaMetadata.METADATA_KEY_ARTIST, fullSubtitle)
            .putString(MediaMetadata.METADATA_KEY_ALBUM, "القرآن الكريم")
            .putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, artBitmap)
            .putBitmap(MediaMetadata.METADATA_KEY_ART, artBitmap)
        if (durationMs > 0L) {
            metaBuilder.putLong(MediaMetadata.METADATA_KEY_DURATION, durationMs)
        }
        session.setMetadata(metaBuilder.build())

        // Update MediaSession PlaybackState (drives the live scrubber, elapsed/remaining time, and lock-screen transport)
        val stateCode = if (isPlaying) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        val speed = if (isPlaying) 1.0f else 0.0f
        val actions = PlaybackState.ACTION_PLAY or
            PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_PLAY_PAUSE or
            PlaybackState.ACTION_SEEK_TO or
            PlaybackState.ACTION_SKIP_TO_PREVIOUS or
            PlaybackState.ACTION_SKIP_TO_NEXT or
            PlaybackState.ACTION_REWIND or
            PlaybackState.ACTION_FAST_FORWARD or
            PlaybackState.ACTION_STOP

        val playbackState = PlaybackState.Builder()
            .setActions(actions)
            .setState(stateCode, positionMs, speed, SystemClock.elapsedRealtime())
            .addCustomAction("mode", modeLabel, modeIconRes)
            .build()
        session.setPlaybackState(playbackState)

        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_TAB, TAB_QURAN)
        }
        val contentFlags = PendingIntent.FLAG_UPDATE_CURRENT or
            (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        val contentPending = PendingIntent.getActivity(this, 4400, openIntent, contentFlags)

        val toggleLabel = if (isPlaying) "Pause" else "Play"
        val toggleIcon = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play

        val rewAction = Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_media_rew),
            "-5s",
            mediaActionPendingIntent("rewind", 4402)
        ).build()

        val toggleAction = Notification.Action.Builder(
            Icon.createWithResource(this, toggleIcon),
            toggleLabel,
            mediaActionPendingIntent("toggle", 4403)
        ).build()

        val ffAction = Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_media_ff),
            "+5s",
            mediaActionPendingIntent("fast_forward", 4404)
        ).build()

        val modeAction = Notification.Action.Builder(
            Icon.createWithResource(this, modeIconRes),
            modeLabel,
            mediaActionPendingIntent("mode", 4406)
        ).build()

        val mediaStyle = Notification.MediaStyle()
            .setMediaSession(session.sessionToken)
            .setShowActionsInCompactView(0, 1, 2)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, MEDIA_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder
            .setStyle(mediaStyle)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(artBitmap)
            .setContentTitle(title)
            .setContentText(fullSubtitle)
            .setContentIntent(contentPending)
            .setOngoing(isPlaying)
            .setOnlyAlertOnce(true)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setColor(Color.parseColor("#171A21"))
            .setColorized(true)
            .addAction(rewAction)
            .addAction(toggleAction)
            .addAction(ffAction)
            .addAction(modeAction)

        manager.notify(MEDIA_NOTIFICATION_ID, builder.build())
    }

    private fun cancelMediaNotification() {
        mediaSession?.isActive = false
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(MEDIA_NOTIFICATION_ID)
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
