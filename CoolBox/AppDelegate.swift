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
        
        sleep(1)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GuidVC()
        window?.makeKeyAndVisible()
        
        return true
    }


}

