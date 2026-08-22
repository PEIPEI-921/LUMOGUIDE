package com.app.lumotrip

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * FCM 推送服务（Android）：
 * - onMessageReceived：App 在前台时展示本地通知（后台由系统自动展示）；
 *   通知 data 携带 conversation_id/message_id/sender_id，点击跳转聊天页。
 * - onNewToken：token 轮换时保存到 SharedPreferences（Dart 侧启动时读取并上报）。
 */
class FcmService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)

        val data = message.data
        val title = message.notification?.title ?: data["title"] ?: "新消息"
        val body = message.notification?.body ?: data["body"] ?: "您有一条新消息"

        // 前台（应用可见）时：需要自己展示通知；后台由系统自动展示。
        // 点击通知 → PendingIntent → MainActivity（携带 conversation_id）→ Dart 跳转聊天页。
        showNotification(title, body, data)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        saveToken(this, token)
        MainActivity.notifyToken(token)
    }

    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        if (!hasNotificationPermission()) return

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            // 透传聊天跳转参数
            putExtra("conversation_id", data["conversation_id"])
            putExtra("message_id", data["message_id"])
            putExtra("sender_id", data["sender_id"])
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            data["conversation_id"]?.hashCode() ?: System.currentTimeMillis().toInt(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val channel = if (data["type"] == "system") MyApplication.CHANNEL_SYSTEM else MyApplication.CHANNEL_IM
        val notification = NotificationCompat.Builder(this, channel)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        try {
            NotificationManagerCompat.from(this).notify(notificationId(data), notification)
        } catch (e: SecurityException) {
            Log.w("FcmService", "notification permission denied: ${e.message}")
        }
    }

    private fun notificationId(data: Map<String, String>): Int =
        data["conversation_id"]?.hashCode() ?: System.currentTimeMillis().toInt()

    private fun hasNotificationPermission(): Boolean {
        return if (android.os.Build.VERSION.SDK_INT >= 33) {
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) ==
                android.content.pm.PackageManager.PERMISSION_GRANTED
        } else true
    }

    companion object {
        private const val PREFS = "fcm_prefs"
        private const val KEY_TOKEN = "fcm_token"

        fun saveToken(context: Context, token: String) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit().putString(KEY_TOKEN, token).apply()
        }

        fun getToken(context: Context): String? =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY_TOKEN, null)

        fun clear(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit().remove(KEY_TOKEN).apply()
        }
    }
}
