package com.webtoapp.converter.appmaker

import android.content.Context
import android.view.LayoutInflater
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/** Onboarding — factory ID: `select_currency_medium`. */
class SelectCurrencyNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context).inflate(
            R.layout.native_ad_select_currency_medium,
            null
        ) as NativeAdView

        MediumNativeAdBindings.bind(nativeAdView, nativeAd)
        return nativeAdView
    }
}
