//
//  AppDelegate.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Kingfisher
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //MMKV初始化
        DataBase.initialize()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        let authorization = Login.authorization()
        EApiConfig.setApp(url: AppAPIBaseURLString, authorization: authorization)
        
        KingfisherManager.shared.defaultOptions += [
            .cacheOriginalImage,
            .backgroundDecode,
        ]
        
        GlobalConfigManager.shared.requestCompanyInfoConfig()
        GlobalConfigManager.shared.requestSystemoInfoConfig()
        
//        WXApi.startLog(by: .detail) { str in
//            ELog(message: "=========wxlog:\(str)")
//        }

        WXApi.registerApp(AppInfo.WeChat.key, universalLink: AppInfo.WeChat.universalLink)
        
//        WXApi.checkUniversalLinkReady { step, result in
//            ELog(message: "=====wx自检- 步骤\(step), --success:\(result.success), --erroeInfo:\(result.errorInfo), --suggesion:\(result.suggestion)")
//        }
        
        sleep(1)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GuidVC()
        window?.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "apmqpdispatch" {
            AFServiceCenter.handleResponseURL(url) { response in
                if response?.responseCode == .success, let token = response?.result["token"] {
                    NotificationCenter.default.post(name: Notification.Name("AliImportFaPiao"), object: token)
                }
            }
            return true
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "apmqpdispatch" {
            AFServiceCenter.handleResponseURL(url) { response in
                if response?.responseCode == .success, let token = response?.result["token"] {
                    NotificationCenter.default.post(name: Notification.Name("AliImportFaPiao"), object: token)
                }
            }
            return true
        }
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        if let res = resp as? WXChooseInvoiceResp {
            NotificationCenter.default.post(name: Notification.Name("WXImportFaPiao"), object: res.cardAry)
        }
    }

}
