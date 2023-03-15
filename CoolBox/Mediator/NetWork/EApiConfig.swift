//
//  EApiConfig.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import AdSupport

struct EApiConfig {
    
    // 存储 URL，authorization
    private class App {
        var authorization: String?
        var urlString: String
        
        init(url: String, authorization: String? = nil) {
            self.authorization = authorization
            self.urlString = url
        }
    }
    
    private static var app: App?
    
    /// 必须先调用此方法 设置URL，authorization
    static func setApp(url: String, authorization: String?) {
        EApiConfig.app = App(url: url, authorization: authorization)
    }
    
    static func updateApp(authorization: String?) {
        guard let app = EApiConfig.app else {
            fatalError("must call EApiConfig.setApp(url:, authorization:) in AppDelegate")
        }
        app.authorization = authorization
    }

    static func appToken() -> String? {
        return EApiConfig.app?.authorization
    }
    
    static func baseUrl() -> String {
        guard let app = EApiConfig.app else {
            fatalError("must call EApiConfig.setApp(url:, authorization:) in AppDelegate")
        }
        return app.urlString
    }
    
    static func deviceName() -> String {
        return UIDevice.modelName
    }
    
    static func uuidStringMD5() -> String {
        // 处理 idfa 为 0000-0000... 情况
        let uuid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let temp = uuid.replacingOccurrences(of: "0", with: "")
        let length = temp.replacingOccurrences(of: "-", with: "").count
        if length > 4 {
            return uuid.md5.uppercased()
        }
        else { return "" }
    }
    
    static func getAppVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return "v\(version)"
        }
        else {
            return "unkown"
        }
    }
    
    static func md5For(string: String) -> String {
        return string.md5
    }
}
