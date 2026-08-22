package com.app.lumotrip;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

/**
 * 应用入口：创建推送通知渠道（Android 8.0+ 必需）。
 * Manifest 中 android:name="com.app.lumotrip.MyApplication" 指向本类。
 */
public class MyApplication extends Application {

    public static final String CHANNEL_IM = "im_messages";
    public static final String CHANNEL_SYSTEM = "system_messages";

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannels();
    }

    private void createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager manager = getSystemService(NotificationManager.class);

            NotificationChannel imChannel = new NotificationChannel(
                    CHANNEL_IM,
                    "聊天消息",
                    NotificationManager.IMPORTANCE_HIGH);
            imChannel.setDescription("来自聊天会话的新消息");
            imChannel.enableVibration(true);
            manager.createNotificationChannel(imChannel);

            NotificationChannel systemChannel = new NotificationChannel(
                    CHANNEL_SYSTEM,
                    "系统通知",
                    NotificationManager.IMPORTANCE_DEFAULT);
            systemChannel.setDescription("预约、系统消息等通知");
            manager.createNotificationChannel(systemChannel);
        }
    }
}
