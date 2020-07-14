import UIKit
import Flutter
import zpdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, ZaloPaySDKDelegate {
    private var code:Int = 0
    
    // func installSandbox(){
    //     let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: UIAlertController.Style.alert)
    //      let installLink = "https://sandbox.zalopay.com.vn/static/ps_res_2019/ios/enterprise/sandboxmer/install.html"
    //     let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
    //
    //     }
    //     let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
    //         guard let url = URL(string: installLink) else {
    //             return //be safe
    //         }
    //         //
    //
    //
    //         if #available(iOS 10.0, *) {
    //             UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //         } else {
    //             UIApplication.shared.openURL(url)
    //         }
    //     }
    //
    //     alert.addAction(cancelAction)
    //     alert.addAction(installAction)
    //     self.present(alert, animated: true, completion: nil)
    // }
    //    func application(
    //        _ app: UIApplication,
    //        open url: URL,
    //        option:[UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    //        ZaloPaySDK.sharedInstance().application(app, open: url, sourceApplication: "vn.com.vng.zalo",annotation: nil)
    //    }
    func zalopayCompleteWith(_ errorCode: ZPErrorCode, transactionId: String?, zpTranstoken zptranstoken: String?) {
        print("------ errorCode ------: \(errorCode.rawValue)")
        self.code = errorCode.rawValue
        if errorCode.rawValue == 1 {
            print("Thanh toán thành công")
//            self.code = 1
        }else{
            if errorCode.rawValue == -1{//not install
                print("App not installed")
                //                installProduction()
                //                installSandbox()
            }
            print("Thanh toán thất bai, error: \(errorCode.rawValue)")
        }
        
    }
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ZaloPaySDK.sharedInstance()?.initWithAppId(124705)
        let controller = window.rootViewController as? FlutterViewController
        let nativeChannel = FlutterMethodChannel(name: "flutter.native/channelPayOrder", binaryMessenger: controller!.binaryMessenger)
        
//        weak var weakSelf = self
        nativeChannel.setMethodCallHandler { (call, result) -> Void in
            guard call.method == "payOrder" else {
              result(FlutterMethodNotImplemented)
              return
            }
            let args = call.arguments as? [String: Any]
            let  _zptoken = args?["zptoken"] as? String
            print("TOKEN INPUT: ", _zptoken ?? "")
            self.payWithToken(zptoken: _zptoken)
            print("Result herere")
            result(String(self.code))
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func payWithToken(zptoken: String?) {
        ZaloPaySDK.sharedInstance()?.delegate = self as ZaloPaySDKDelegate
        ZaloPaySDK.sharedInstance()?.payOrder(zptoken)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ZaloPaySDK.sharedInstance().application(app, open: url, sourceApplication: "vn.com.vng.zalo",annotation: nil)
    }
    
    
    
}
