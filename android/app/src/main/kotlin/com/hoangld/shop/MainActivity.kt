package com.hoangld.shop

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Bundle
import android.util.Log
import android.widget.Switch
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.listener.ZaloPayListener
import vn.zalopay.sdk.ZaloPayErrorCode
import vn.zalopay.sdk.ZaloPaySDK


class MainActivity: FlutterActivity() {
    private var channelPayOrder: String = "flutter.native/channelPayOrder"
    private var eventPayOrder: String = "flutter.native/eventPayOrder"
    var zlpCodeResponse = "Ops";
    val Sucess = "Thanh Cong"
    val Fail = "That Bai"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ZaloPaySDK.getInstance().initWithAppId(124705); // appId merchant
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        ZaloPaySDK.getInstance().onActivityResult(requestCode, resultCode, data);
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor, eventPayOrder).setStreamHandler(
            object : StreamHandler {
                private var payOrderStateChangeReceiver: BroadcastReceiver? = null
                override fun onListen(arguments: Any?, events: EventSink) {
                    payOrderStateChangeReceiver = createPayOrderStateChangeReceiver(events)

                    registerReceiver(
                            payOrderStateChangeReceiver, IntentFilter(zlpCodeResponse))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(payOrderStateChangeReceiver)
                    payOrderStateChangeReceiver = null
                }
            }

        )

        // payOrder
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
                            zlpCodeResponse =  Sucess
                            //
                        }

                        override fun onPaymentError(zaloPayErrorCode: ZaloPayErrorCode, paymentErrorCode: Int, zpTransToken: String) {
                            Log.d(tagError, String.format("[zaloPayErrorCode]: %s, [paymentErrorCode]: %s, [zpTransToken]: %s", zaloPayErrorCode.toString(), paymentErrorCode.toString(), zpTransToken))
                            if (zaloPayErrorCode == ZaloPayErrorCode.ZALO_PAY_NOT_INSTALLED) {
                                // handle NOT INSTALL
                                result.success("Thanh Toán Thất Bại")
                            } else {
                                result.success("Thanh Toán Thất Bại")
                            }

                            zlpCodeResponse = Fail
                        }
                    })

                } else {
                    Log.d("[METHOD CALLER] ", "Method Not Implemented")
                    result.success("Thanh Toán Thất Bại")
                }
            }

    }

    private fun createPayOrderStateChangeReceiver(events: EventSink): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent) {
                Log.d("intent: ", intent.toString())
                if (intent.dataString == Sucess) {
                    events.success(Sucess);
                } else if (intent.toString() == Fail) {
                    events.success(Fail);
                } else {
                    events.error("UNAVAILABLE", "Ops...", null);
                }

            }
        }
    }

}