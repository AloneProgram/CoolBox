//
//  AppDelegate.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        KingfisherManager.shared.defaultOptions += [
            .cacheOriginalImage,
            .backgroundDecode,
        ]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GuidVC()
        window?.makeKeyAndVisible()
        
        return true
    }


}

