package com.webtoapp.converter.appmaker

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class SmallNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val layoutInflater = LayoutInflater.from(context)
        val adView = layoutInflater.inflate(
            com.webtoapp.converter.appmaker.R.layout.custom_small_native_ad,
            null
        ) as NativeAdView

        try {
            val iconView = adView.findViewById<ImageView>(
                com.webtoapp.converter.appmaker.R.id.ad_icon
            )
            val mediaView = adView.findViewById<MediaView>(
                com.webtoapp.converter.appmaker.R.id.ad_media
            )
            val headlineView = adView.findViewById<TextView>(
                com.webtoapp.converter.appmaker.R.id.ad_headline
            )
            val bodyView = adView.findViewById<TextView>(
                com.webtoapp.converter.appmaker.R.id.ad_body
            )
            val callToActionView = adView.findViewById<TextView>(
                com.webtoapp.converter.appmaker.R.id.ad_call_to_action
            )
            val mediaContainer = adView.findViewById<View>(
                com.webtoapp.converter.appmaker.R.id.ad_media_container
            )

            // Always register asset views so the SDK can populate them.
            mediaView?.let { adView.mediaView = it }
            iconView?.let { adView.iconView = it }

            // Left slot is for ad media; fall back to app icon only when no media.
            val hasMedia = nativeAd.mediaContent != null
            when {
                hasMedia && mediaView != null -> {
                    mediaContainer?.visibility = View.VISIBLE
                    mediaView.visibility = View.VISIBLE
                    iconView?.visibility = View.GONE
                }
                nativeAd.icon != null && iconView != null -> {
                    mediaContainer?.visibility = View.VISIBLE
                    iconView.visibility = View.VISIBLE
                    mediaView?.visibility = View.GONE
                }
                else -> {
                    mediaContainer?.visibility = View.GONE
                    iconView?.visibility = View.GONE
                    mediaView?.visibility = View.GONE
                }
            }

            headlineView?.let {
                adView.headlineView = it
                it.visibility = View.VISIBLE
            }

            bodyView?.let {
                adView.bodyView = it
                it.visibility = View.VISIBLE
            }

            callToActionView?.let {
                adView.callToActionView = it
            }

            adView.setNativeAd(nativeAd)

            headlineView?.let {
                nativeAd.headline?.let { headline -> it.text = headline }
            }
            bodyView?.let {
                nativeAd.body?.let { body -> it.text = body }
            }
            callToActionView?.let {
                nativeAd.callToAction?.let { cta -> it.text = cta }
            }
        } catch (e: Exception) {
            android.util.Log.e(
                "SmallNativeAdFactory",
                "Error setting up native ad: ${e.message}",
                e
            )
        }

        return adView
    }
}
