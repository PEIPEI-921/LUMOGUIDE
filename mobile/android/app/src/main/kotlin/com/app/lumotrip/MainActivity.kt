package com.app.lumotrip

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Android 推送通道：与 iOS AppDelegate 同一协议（MethodChannel "lumotrip/push"）。
 *
 * Dart 调用：register / getToken / setBadge / getPendingNotification
 * 原生回调：onTokenReceived / onNotificationTap（FcmService 或通知点击触发）
 */
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "lumotrip/push"
        private const val REQ_NOTIFICATION = 1001
        private var channel: MethodChannel? = null
        private var activity: MainActivity? = null

        /** FCM token 轮换时通知 Dart 重新上报（App 存活时） */
        fun notifyToken(token: String) {
            val ch = channel ?: return
            activity?.runOnUiThread { ch.invokeMethod("onTokenReceived", token) }
        }
    }

    /** 通知点击跳转参数（冷启动时由 onCreate 缓存，Dart 就绪后拉取） */
    private var pendingTap: MutableMap<String, Any>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        activity = this
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(object : MethodChannel.MethodCallHandler {
            override fun onMethodCall(call: MethodCall, reply: MethodChannel.Result) {
                when (call.method) {
                    "register" -> {
                        requestNotificationPermissionAndFetchToken()
                        flushPendingTap()
                        reply.success(null)
                    }
                    "getToken" -> reply.success(FcmService.getToken(this@MainActivity) ?: "")
                    "setBadge" -> reply.success(null) // Android 无通用角标 API，忽略
                    "getPendingNotification" -> {
                        val p = pendingTap
                        pendingTap = null
                        reply.success(p)
                    }
                    else -> reply.notImplemented()
                }
            }
        })
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureTapFromIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureTapFromIntent(intent)
    }

    /** 通知点击（通知 PendingIntent → MainActivity）携带 conversation_id 时缓存/透传 */
    private fun captureTapFromIntent(intent: Intent?) {
        val convId = intent?.getStringExtra("conversation_id")
        if (convId.isNullOrEmpty()) return
        pendingTap = mutableMapOf(
            "conversation_id" to convId,
            "message_id" to (intent.getStringExtra("message_id") ?: ""),
            "sender_id" to (intent.getStringExtra("sender_id") ?: ""),
        )
        flushPendingTap()
    }

    private fun flushPendingTap() {
        val p = pendingTap ?: return
        pendingTap = null
        channel?.invokeMethod("onNotificationTap", p)
    }

    /** 申请通知权限（Android 13+）并获取 FCM token */
    private fun requestNotificationPermissionAndFetchToken() {
        if (Build.VERSION.SDK_INT >= 33) {
            val granted = ContextCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    REQ_NOTIFICATION,
                )
                return
            }
        }
        fetchToken()
    }

    private fun fetchToken() {
        FirebaseMessaging.getInstance().token
            .addOnSuccessListener { token ->
                FcmService.saveToken(this, token)
                channel?.invokeMethod("onTokenReceived", token)
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_NOTIFICATION) {
            fetchToken()
        }
    }

    override fun onDestroy() {
        if (activity === this) activity = null
        super.onDestroy()
    }
}
