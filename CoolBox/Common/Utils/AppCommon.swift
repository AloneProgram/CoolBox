//
//  AppCommon.swift
//  huandian
//
//  Created by Jhin on 2020/9/15.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import Alamofire

struct AppCommon {
        /// 获取当前控制器
    public static func getCurrentVC() -> UIViewController? {
        
        guard var window = UIApplication.shared.keyWindow else { return nil }
        
        if window.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for obj in windows {
                if obj.windowLevel == UIWindow.Level.normal {
                    window = obj
                    break
                }
            }
        }
        
        if var result = window.rootViewController {
            while result.presentedViewController != nil {
                result = result.presentedViewController!
            }
            if result is UITabBarController {
                let temp = result as! UITabBarController
                result = (temp.viewControllers?[temp.selectedIndex])!
            }
            if result is UINavigationController {
                let temp = result as! UINavigationController
                result = temp.topViewController!
            }
            return result
        }
        return nil
    }
    
    
    
    static func AlamofiremonitorNet() -> Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus? {
        let manager = NetworkReachabilityManager(host: "www.baidu.com")
        if manager?.status == .reachable(.ethernetOrWiFi) { //WIFI
            print("wifi")
        } else if manager?.status == .reachable(.cellular) { // 移动数据
            print("4G")
        } else if manager?.status == .notReachable { // 无网络
            print("无网络")
        } else { // 其他
            
        }
        return manager?.status
    }
    
    static func nerWorkIsReachable() -> Bool? {
        let manager = NetworkReachabilityManager(host: "www.baidu.com")
        return manager?.isReachable
    }
}
