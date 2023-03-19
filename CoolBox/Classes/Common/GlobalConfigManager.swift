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
    
    func requestCompanyInfoConfig() {
        CommonApi.getCompanyConfig()
    }
}
