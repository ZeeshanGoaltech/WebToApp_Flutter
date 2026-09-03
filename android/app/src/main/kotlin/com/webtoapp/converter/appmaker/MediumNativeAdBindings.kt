package com.webtoapp.converter.appmaker

import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

/** Shared bind logic for Nail Art–style medium native layouts. */
internal object MediumNativeAdBindings {
    fun bind(
        nativeAdView: NativeAdView,
        nativeAd: NativeAd,
    ) {
        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val iconView = nativeAdView.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<TextView>(R.id.ad_call_to_action)

        nativeAdView.headlineView = headlineView
        nativeAdView.bodyView = bodyView
        nativeAdView.callToActionView = ctaView
        nativeAdView.mediaView = mediaView
        nativeAdView.iconView = iconView

        headlineView.text = nativeAd.headline

        nativeAd.body?.let {
            bodyView.text = it
            bodyView.visibility = View.VISIBLE
        } ?: run {
            bodyView.visibility = View.GONE
        }

        val hasMedia = nativeAd.mediaContent != null
        if (hasMedia) {
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.visibility = View.VISIBLE
            iconView.visibility = View.GONE
        } else {
            mediaView.visibility = View.GONE
            nativeAd.icon?.let {
                iconView.setImageDrawable(it.drawable)
                iconView.visibility = View.VISIBLE
            } ?: run {
                iconView.visibility = View.GONE
            }
        }

        nativeAd.callToAction?.let {
            ctaView.text = it
            ctaView.visibility = View.VISIBLE
        } ?: run {
            ctaView.visibility = View.GONE
        }

        nativeAdView.setNativeAd(nativeAd)
    }
}
