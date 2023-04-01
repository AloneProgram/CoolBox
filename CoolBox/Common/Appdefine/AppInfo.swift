//
//  AppInfo.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation

struct AppInfo {
    static let appName = "酷报销"
    static let id = 0
    static let scheme = ""
    static let host = ""

    static let companyName = ""
    static let companyEnName = ""

    
    /// 微信
    struct WeChat {
        static let key = "wxd0ab460cc82817d4"
        static let secret = ""
        /// 不可修改
        static let bundleId = "com.tencent.xin"
        static let universalLink = "https://app.kubaoxiao.com/app/"
    }
    
    struct AliPay {
        static let scheme = "2021003162694292"
    }
    
    // scheme 白名单
    static let whiteSchemes = [
        "mqqapi",
        "mqq",
        "sinaweibo",
        "weibosdk",
        "wechat",
        "weixin"
    ]

    
}
