//
//  AppInfo.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation

private enum AppInfoType: Int {
    // 测试
    case test = 0
    // 开发
    case develop = 1
    // 预发布
    case release = 2
    // 生产
    case prod = 3
}

//#if RELEASE
//private let apiType: AppInfoType = .prod
//#else
//private func getApiType() -> AppInfoType {
//    let value = UserDefaults.standard.value(forKeyPath: "\(ApiBaseURLKey).apiType")
//    if let temp = value as? Int, let apiType = AppInfoType(rawValue: temp) {
//        return apiType
//    }
//    else {
//        return .test
//    }
//}

//private let apiType = getApiType()
//#endif

struct AppInfo {
    static let appName = "欢电"
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
    
    ///友盟
    struct UMeng {
        static let key = ""
    }
    
    ///高德
    struct AMAp {
        static let key = "c1030943484b93844ccc9a06cbc24b68"
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
