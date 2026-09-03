package com.webtoapp.converter.appmaker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    companion object {
        private const val WEBVIEW_WARMUP_CHANNEL =
            "com.webtoapp.converter/webview_warmup"
    }

    @Volatile
    private var webViewWarmedUp = false

    private var warmingStarted = false
    private val pendingWarmupResults = mutableListOf<MethodChannel.Result>()

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
        // Fallback only: Dart calls warmUp before MobileAds.initialize.
        // If that path is skipped, still warm once after splash settles.
        window.decorView.postDelayed({
            if (!webViewWarmedUp) warmUpWebViewForAds(result = null)
        }, 2_500L)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WEBVIEW_WARMUP_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "warmUp" -> warmUpWebViewForAds(result)
                else -> result.notImplemented()
            }
        }

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

        try {
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "mediumfullCTA",
                MediumFullCtaNativeAdFactory(this),
            )
        } catch (e: Exception) {
            android.util.Log.e(
                "MainActivity",
                "Failed to register mediumfullCTA: ${e.message}",
                e,
            )
        }

        try {
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "select_currency_medium",
                SelectCurrencyNativeAdFactory(this),
            )
        } catch (e: Exception) {
            android.util.Log.e(
                "MainActivity",
                "Failed to register select_currency_medium: ${e.message}",
                e,
            )
        }

    }

    /**
     * Loads System WebView / Chromium native libs once on the UI thread.
     * Must finish before AdMob creates its ads.internal.js WebView, otherwise
     * nativeLoadWithRelroFile blocks during ad init (ANR on low-end devices).
     * Does not change ad requests, GDPR, or IAP behavior.
     */
    private fun warmUpWebViewForAds(result: MethodChannel.Result?) {
        if (webViewWarmedUp) {
            result?.success(true)
            return
        }
        if (result != null) {
            pendingWarmupResults.add(result)
        }
        if (warmingStarted) return
        warmingStarted = true

        if (isFinishing || isDestroyed) {
            completeWarmupResults(false)
            return
        }

        val runWarmup = Runnable {
            if (webViewWarmedUp) {
                completeWarmupResults(true)
                return@Runnable
            }
            if (isFinishing || isDestroyed) {
                completeWarmupResults(false)
                return@Runnable
            }

            var webView: WebView? = null
            try {
                // Activity context — applicationContext WebView can crash on some OEMs.
                webView = WebView(this@MainActivity).apply {
                    settings.javaScriptEnabled = false
                    // Exercises provider bind + navigation path Ads uses later.
                    loadUrl("about:blank")
                }
                webViewWarmedUp = true
                completeWarmupResults(true)
                webView.postDelayed({
                    try {
                        webView?.stopLoading()
                        webView?.destroy()
                    } catch (_: Throwable) {
                    }
                }, 500L)
            } catch (t: Throwable) {
                android.util.Log.w(
                    "MainActivity",
                    "WebView warmup skipped: ${t.message}",
                )
                try {
                    webView?.destroy()
                } catch (_: Throwable) {
                }
                completeWarmupResults(false)
            }
        }

        // Prefer posting so we are not nested inside an unrelated message;
        // window focus is usually present by the time splash asks for warmup.
        window.decorView.post(runWarmup)
    }

    private fun completeWarmupResults(ok: Boolean) {
        val results = pendingWarmupResults.toList()
        pendingWarmupResults.clear()
        for (r in results) {
            try {
                r.success(ok)
            } catch (_: Throwable) {
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "mediumAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "mediumfullCTA")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "select_currency_medium")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
