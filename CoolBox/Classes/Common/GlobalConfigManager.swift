//
//  GlobalConfigManager.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class GlobalConfigManager: NSObject {
    ///单例,唯一调用方法
    static let shared = GlobalConfigManager()
    
    var companyInfoConfig: CompanyInfoConfig?
    
    var systemoInfoConfig: SystemConfigInfo?
    
    func requestCompanyInfoConfig() {
        CommonApi.getCompanyConfig()
    }
    
    func requestSystemoInfoConfig() {
        CommonApi.getSystemConfig()
    }
    
   static  func getValue(with key: String, in dic: [String: String]?) -> String {
        guard let dic = dic else {
            return ""
        }
        return dic[key] ?? ""
    }
    
    static func getKey(with value: String, in dic: [String: String]?) -> String {
        guard let dic = dic else {
            return ""
        }
        var idx = -1
        dic.values.enumerated().forEach { i, str in
            if str == value {
                idx = i
            }
        }
        guard idx >= 0 else { return ""}
        return Array(dic.keys)[idx]
    }
}
