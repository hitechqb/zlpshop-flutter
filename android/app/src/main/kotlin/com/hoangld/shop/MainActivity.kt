package com.hoangld.shop

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.listener.ZaloPayListener
import vn.zalopay.sdk.ZaloPayErrorCode
import vn.zalopay.sdk.ZaloPaySDK

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ZaloPaySDK.getInstance().initWithAppId(2554); // appId merchant
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        ZaloPaySDK.getInstance().onActivityResult(requestCode, resultCode, data);
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channelPayOrder = "flutter.native/channelPayOrder"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelPayOrder)
            .setMethodCallHandler { call, result ->
                if (call.method == "payOrder"){
                    val tagSuccess = "[OnPaymentSucceeded]"
                    val tagError = "[onPaymentError]"
                    val token = call.argument<String>("zptoken")

                    ZaloPaySDK.getInstance().payOrder(this@MainActivity, token !!, object : ZaloPayListener {
                        override fun onPaymentSucceeded(transactionId: String, transToken: String) {
                            Log.d(tagSuccess, String.format("[TransactionId]: %s, [TransToken]: %s", transactionId, transToken))
                            result.success("Thanh Toán Thành Công")
                        }

                        override fun onPaymentError(zaloPayErrorCode: ZaloPayErrorCode, paymentErrorCode: Int, zpTransToken: String) {
                            Log.d(tagError, String.format("[zaloPayErrorCode]: %s, [paymentErrorCode]: %s, [zpTransToken]: %s", zaloPayErrorCode.toString(), paymentErrorCode.toString(), zpTransToken))
                            if (zaloPayErrorCode == ZaloPayErrorCode.ZALO_PAY_NOT_INSTALLED) {
                                // handle NOT INSTALL
                                 result.success("Thanh Toán Thất Bại")
                            } else {
                                result.success("Thanh Toán Thất Bại")
                            }
                        }
                    })
                } else {
                    Log.d("[METHOD CALLER] ", "Method Not Implemented")
                    result.success("Thanh Toán Thất Bại")
                }
            }
    }
}