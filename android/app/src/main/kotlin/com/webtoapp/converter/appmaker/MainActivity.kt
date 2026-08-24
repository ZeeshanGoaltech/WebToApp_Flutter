package com.webtoapp.converter.appmaker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "Push Notifications",
                NotificationManager.IMPORTANCE_HIGH,
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        try {
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "smallAd",
                SmallNativeAdFactory(this),
            )
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to register smallAd: ${e.message}", e)
        }

        try {
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "mediumAd",
                VerticalMediumNativeAdFactory(this),
            )
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to register mediumAd: ${e.message}", e)
        }

        PackIapDebug.register(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "mediumAd")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
