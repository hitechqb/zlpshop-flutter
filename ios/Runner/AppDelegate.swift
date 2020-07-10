import UIKit
import Flutter
import zpdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, ZaloPaySDKDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     
    let controller = window.rootViewController as? FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "flutter.native/channelPayOrder", binaryMessenger: controller!.binaryMessenger)
    
    weak var weakSelf = self
    nativeChannel.setMethodCallHandler { (call, result) in
        if ("payOrder" == call.method) {
            let _zptoken = call.arguments as! String
            print("TOKEN INPUT: ", _zptoken)
            let strNative = weakSelf?.payWithToken(zptoken: _zptoken)
                   result(strNative)
               } else {
                   result(FlutterMethodNotImplemented)
               }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    ZaloPaySDK.sharedInstance()?.initWithAppId(124705)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func payWithToken(zptoken: String?) -> String? {
        ZaloPaySDK.sharedInstance()?.delegate = self as ZaloPaySDKDelegate
        ZaloPaySDK.sharedInstance()?.payOrder(zptoken)
        return "Thanh toán Thành công"
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        option:[UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        ZaloPaySDK.sharedInstance().application(app, open: url, sourceApplication: "vn.com.vng.zalo",annotation: nil)
    }
    
    func zalopayCompleteWith(_ errorCode: ZPErrorCode, transactionId: String?, zpTranstoken zptranstoken: String?) {
        print("------ errorCode ------: \(errorCode.rawValue)")

        if errorCode.rawValue == 1 {
            print("Thanh toán thành công")
        }else{
            print("Thanh toán thất bai, error: \(errorCode.rawValue)")
        }
    }
}

