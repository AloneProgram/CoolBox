
//
//  AppRouter.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

protocol AppRouter {
    /// url: yetinglive://yetinglive.com/wallet
    func canHandleUrl(_ url: URL?) -> Bool
    func canHandleUrl(_ urlString: String?) -> Bool
}

extension UIViewController: AppRouter {
    func canHandleUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        return AppRouterTool.canHandleUrl(url, vc: self)
    }
    
    func canHandleUrl(_ urlString: String?) -> Bool {
        guard let url = urlString else { return false }
        return canHandleUrl(URL(string: url))
    }
}
    
// 路由处理
struct AppRouterTool {
    
    /// 待处理的 路由事件，在APP尚未启动之前或者首页未显示
    fileprivate static var waitHandleUrl: URL? = nil
    
    static func doWaitHandleUrl(_ vc: UIViewController?) -> Bool {
        guard let url = waitHandleUrl else { return false }
        waitHandleUrl = nil // 重置
        
        guard var tempVC = vc else { return false }
        if let tabbarVC = tempVC as? UITabBarController,
            let first =  tabbarVC.viewControllers?.first {
            tempVC = first
        }
        return tempVC.canHandleUrl(url)
    }
    
    static func canHandleUrl(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        guard url.scheme != nil else { return false }
        if let vc = getTabBarSelectedViewController() {
            return canHandleUrl(url, vc: vc)
        }
        else {
            waitHandleUrl = url
            return true
        }
    }
}

fileprivate extension AppRouterTool {
    
    static func canHandleUrl(_ url: URL, vc: UIViewController) -> Bool {
        guard let scheme = url.scheme else { return false }
        if scheme.hasPrefix("http") {
            vc.pushToWebView(url.absoluteString)
            return true
        }
        else if scheme.hasPrefix(AppInfo.scheme) {
            // app 处理
            return canHandleAppUrl(url, vc: vc)
        }
        else if AppInfo.whiteSchemes.contains(scheme),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
    
    static func canHandleAppUrl(_ url: URL, vc: UIViewController) -> Bool {
        guard let host = url.host, host.contains(AppInfo.host) else { return false }
        guard let path = url.pathComponents.last else { return false}
        print("canHandleAppUrl path = ", path)
        
        guard let type = AppRouterDisPatch(rawValue: path) else { return false }
        guard !type.isTabbar else { return specialTabbar(url, vc: vc, type: type) }
        
        guard let cls = type.cls else { return false}
        let params = url.queryDictionary
        print("canHandleAppUrl params = ", params ?? "no params")
        
        //FIXME: 相同 vc, 如果需要跳转呢
        if vc.classForCoder.self == cls { return false }
        // 特殊处理
        vc.push(cls.init(), params: params)
       
        return true
    }
    
    // 特殊：需要跳转到 tabbar
    static func specialTabbar(_ url: URL, vc: UIViewController, type: AppRouterDisPatch) -> Bool {
        guard getTabBarController() != nil else { return false }
//        let params = url.queryDictionary
        return false
    }
    
    /// 获取当前 tabbarvc
    static func getTabBarController() -> UITabBarController? {
        
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
                return result as? UITabBarController
            }
        }
        return nil
    }
    
    static func getTabBarSelectedViewController() -> UIViewController? {
        let vc = getTabBarController()?.selectedViewController
        if let nav = vc as? UINavigationController {
            return nav.topViewController
        }
        return vc
    }
}

private enum AppRouterDisPatch: String {
    case unkown

    
    var cls: UIViewController.Type? {
        switch self {
        case .unkown:       return nil
        }
    }
    
    var isTabbar: Bool {
        switch self {
        default: return false
        }
    }
}

private extension URL {
    var queryDictionary: [String: String]? {
        //TODO: path 带 # 不能正确解析到query
        guard let query = self.query else { return nil }
        
        var queryStrings: [String: String] = [:]
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}
