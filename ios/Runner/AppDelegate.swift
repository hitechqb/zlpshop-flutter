import UIKit
import Flutter
import zpdk


// chanel Init to handle Channel Flutter
enum ChannelName {
  static let channelPayOrder = "flutter.native/channelPayOrder"
  static let eventPayOrder = "flutter.native/eventPayOrder"
}

// methods define to handle in channel
enum MethodNames {
    static let methodPayOrder = "payOrder"
}


// mapping with ZPErrorCode
enum ErroCodeState {
    static var codes: Int = -9
    static let sucess = 1
    static let notInstall = -1
    static let invalidResponse = -2
    static let invalidOrder = -3
    static let userCancel = -4
    static let fail = -5
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler, ZaloPaySDKDelegate {
    private var eventSink: FlutterEventSink?
    
     override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
 
        return ZaloPaySDK.sharedInstance().application(app, open: url, sourceApplication: "vn.com.vng.zalo", annotation: nil)
        
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        ZaloPaySDK.sharedInstance()?.initWithAppId(2554)
     
        // handle channel in native iOS
        let controller = window.rootViewController as? FlutterViewController
        let nativeChannel = FlutterMethodChannel(name: ChannelName.channelPayOrder, binaryMessenger: controller!.binaryMessenger)
        
        nativeChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == MethodNames.methodPayOrder else {
              result(FlutterMethodNotImplemented)
              return
            }
            
            let args = call.arguments as? [String: Any]
            let  _zptoken = args?["zptoken"] as? String
 
            ZaloPaySDK.sharedInstance()?.delegate = self
            ZaloPaySDK.sharedInstance()?.payOrder(_zptoken)
            result("Processing...")
        })
             
        let eventPayOrderChannel = FlutterEventChannel(name: ChannelName.eventPayOrder,
                                                  binaryMessenger: controller!.binaryMessenger)
        
        eventPayOrderChannel.setStreamHandler(self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // handle payment error code
    func zalopayCompleteWith(_ errorCode: ZPErrorCode, transactionId: String!, zpTranstoken zptranstoken: String!) {
         print("------ errorCode ------: \(errorCode.rawValue)")
         ErroCodeState.codes = errorCode.rawValue
        
        if errorCode.rawValue == 1 {
            print("Thanh toán thành công")
        }else{
            if errorCode.rawValue == -1{//not install
                print("App not installed")
//                installProduction()
                installSandbox()
            }
            print("Thanh toán thất bại, error: \(errorCode.rawValue)")
        }
        
        dispatchPayOrderEvent()
    }
    
    func installSandbox(){
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: UIAlertController.Style.alert)
        let installLink = "https://sandbox.zalopay.com.vn/static/ps_res_2019/ios/enterprise/sandboxmer/install.html"
        let controller = window.rootViewController as? FlutterViewController
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in

        }
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
            guard let url = URL(string: installLink) else {
                return //be safe
            }
            //


            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(installAction)
        controller?.present(alert, animated: true, completion: nil)
    }
    
    func installProduction(){
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: UIAlertController.Style.alert)
        let controller = window.rootViewController as? FlutterViewController
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in

        }
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
            ZaloPaySDK.sharedInstance()?.navigateToStore()
        }
        alert.addAction(cancelAction)
        alert.addAction(installAction)
        controller?.present(alert, animated: true, completion: nil)
    }
    
    // func implement with FlutterStreamHandler
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
     }

    // func implement with FlutterStreamHandler
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    // dispatch event and sink value flutter
    private func dispatchPayOrderEvent() {
      guard let eventSink = eventSink else {
        return
      }
      
      switch ErroCodeState.codes {
      case ErroCodeState.sucess:
        eventSink(ErroCodeState.sucess)
        
      case ErroCodeState.notInstall:
        eventSink(ErroCodeState.notInstall)
        
      case ErroCodeState.invalidResponse:
        eventSink(ErroCodeState.invalidResponse)
        
      case ErroCodeState.invalidOrder:
        eventSink(ErroCodeState.invalidOrder)
        
      case ErroCodeState.userCancel:
        eventSink(ErroCodeState.userCancel)
      
      case ErroCodeState.fail:
        eventSink(ErroCodeState.fail)
    
      default:
        eventSink(FlutterError(code: "Ops...",
                               message: "Code not define in ZaloPayCode",
                               details: nil))
      }
    }
}
