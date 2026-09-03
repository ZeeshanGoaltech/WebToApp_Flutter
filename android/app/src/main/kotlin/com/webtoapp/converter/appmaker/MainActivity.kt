package com.webtoapp.converter.appmaker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.webkit.WebView
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
        // AdMob creatives use System WebView. First Chromium bind + loadUrl on the
        // main thread during a tap causes "Input dispatching timed out" ANRs
        // (J.N.VOZ / InterceptNavigationDelegate). Warm the provider during splash
        // so the first ad load is cheaper — does not change ad/IAP behavior.
        window.decorView.postDelayed({ warmUpWebViewForAds() }, 1_200L)
    }

    private fun warmUpWebViewForAds() {
        if (isFinishing || isDestroyed) return
        var webView: WebView? = null
        try {
            webView = WebView(this).apply {
                settings.javaScriptEnabled = false
                // about:blank exercises the same navigation path Ads uses,
                // resolving native methods before user-facing ad loads.
                loadUrl("about:blank")
            }
            webView.postDelayed({
                try {
                    webView?.stopLoading()
                    webView?.destroy()
                } catch (_: Throwable) {
                }
            }, 600L)
        } catch (t: Throwable) {
            android.util.Log.w(
                "MainActivity",
                "WebView warmup skipped: ${t.message}",
            )
            try {
                webView?.destroy()
            } catch (_: Throwable) {
            }
        }
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
