package com.webtoapp.converter.appmaker

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.ProductDetailsResponseListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryProductDetailsResult
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Diginotes-style Play Billing dump for one-time pack multi-offers + tokens. */
object PackIapDebug {
    private const val CHANNEL = "pack_iap_debug"

    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != "dumpPackOffers") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val productId = call.argument<String>("productId").orEmpty()
            if (productId.isEmpty()) {
                result.error("bad_args", "productId missing", null)
                return@setMethodCallHandler
            }
            dumpOffers(context, productId, result)
        }
    }

    private fun dumpOffers(
        context: Context,
        productId: String,
        result: MethodChannel.Result,
    ) {
        val main = Handler(Looper.getMainLooper())
        val client = BillingClient.newBuilder(context)
            .setListener { _, _ -> }
            .enablePendingPurchases(
                PendingPurchasesParams.newBuilder().enableOneTimeProducts().build(),
            )
            .enableAutoServiceReconnection()
            .build()

        client.startConnection(
            object : BillingClientStateListener {
                override fun onBillingSetupFinished(billingResult: BillingResult) {
                    if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                        main.post {
                            result.success(
                                mapOf(
                                    "ok" to false,
                                    "setupResponseCode" to billingResult.responseCode,
                                    "setupDebugMessage" to billingResult.debugMessage,
                                ),
                            )
                            client.endConnection()
                        }
                        return
                    }

                    val params = QueryProductDetailsParams.newBuilder()
                        .setProductList(
                            listOf(
                                QueryProductDetailsParams.Product.newBuilder()
                                    .setProductId(productId)
                                    .setProductType(BillingClient.ProductType.INAPP)
                                    .build(),
                            ),
                        )
                        .build()

                    client.queryProductDetailsAsync(
                        params,
                        ProductDetailsResponseListener { queryResult: BillingResult, detailsResult: QueryProductDetailsResult ->
                            val products: List<ProductDetails> = detailsResult.productDetailsList
                            val flattened = flattenOneTimeOffers(products)
                            val cheapest = flattened.minByOrNull { offerMicros(it) }
                            val highest = flattened.maxByOrNull { offerMicros(it) }
                            val payload = hashMapOf<String, Any?>(
                                "ok" to (queryResult.responseCode == BillingClient.BillingResponseCode.OK),
                                "queryResponseCode" to queryResult.responseCode,
                                "queryDebugMessage" to queryResult.debugMessage,
                                "productId" to productId,
                                "productCount" to products.size,
                                "products" to products.map { productJson(it) },
                                "flattenedOffers" to flattened,
                                "cheapestOffer" to cheapest,
                                "highestOffer" to highest,
                            )
                            main.post {
                                result.success(payload)
                                client.endConnection()
                            }
                        },
                    )
                }

                override fun onBillingServiceDisconnected() {}
            },
        )
    }

    private fun productJson(details: ProductDetails): Map<String, Any?> {
        val oneTime = details.oneTimePurchaseOfferDetails
        val oneTimeList = try {
            details.oneTimePurchaseOfferDetailsList
        } catch (_: Throwable) {
            null
        }
        return hashMapOf(
            "productId" to details.productId,
            "productType" to details.productType,
            "name" to details.name,
            "title" to details.title,
            "oneTimePurchaseOfferDetails" to oneTime?.let { oneTimeJson(it) },
            "oneTimePurchaseOfferDetailsList" to oneTimeList?.map { oneTimeJson(it) },
        )
    }

    private fun flattenOneTimeOffers(
        products: List<ProductDetails>,
    ): List<Map<String, Any?>> {
        val offers = mutableListOf<Map<String, Any?>>()
        for (details in products) {
            val list = try {
                details.oneTimePurchaseOfferDetailsList
            } catch (_: Throwable) {
                null
            }
            if (!list.isNullOrEmpty()) {
                offers.addAll(list.map { oneTimeJson(it) })
            } else {
                details.oneTimePurchaseOfferDetails?.let { offers.add(oneTimeJson(it)) }
            }
        }
        return offers
    }

    private fun offerMicros(offer: Map<String, Any?>): Long {
        return (offer["priceAmountMicros"] as? Number)?.toLong() ?: Long.MAX_VALUE
    }

    private fun oneTimeJson(offer: ProductDetails.OneTimePurchaseOfferDetails): Map<String, Any?> {
        return hashMapOf(
            "formattedPrice" to offer.formattedPrice,
            "priceAmountMicros" to offer.priceAmountMicros,
            "priceCurrencyCode" to offer.priceCurrencyCode,
            "offerId" to invokeString(offer, "getOfferId"),
            "offerToken" to offerTokenOf(offer),
            "purchaseOptionId" to invokeAny(offer, "getPurchaseOptionId")?.toString(),
        )
    }

    private fun offerTokenOf(offer: ProductDetails.OneTimePurchaseOfferDetails): String? {
        return invokeString(offer, "getOfferToken")?.trim()?.ifEmpty { null }
    }

    private fun invokeString(target: Any, method: String): String? {
        return invokeAny(target, method) as? String
    }

    private fun invokeAny(target: Any, method: String): Any? {
        return try {
            target.javaClass.methods
                .firstOrNull { it.name == method && it.parameterCount == 0 }
                ?.invoke(target)
        } catch (_: Throwable) {
            null
        }
    }
}
