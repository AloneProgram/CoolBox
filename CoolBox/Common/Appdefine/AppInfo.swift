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
    static let scheme = "huandian"
    static let host = ""

    static let companyName = "深圳易马达科技有限公司"
    static let companyEnName = "Shenzhen Immotor Technology Co., Ltd."

    
    /// 微信
    struct WeChat {
        static let key = "wxff283937157c82df"
        static let secret = ""
        /// 不可修改
        static let bundleId = "com.tencent.xin"
        static let universalLink = "https://www.huandian.xin/"
    }
    
    struct AliPay {
        static let key = "ImmotorHuanDian"
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
