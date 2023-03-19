//
//  CommonApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    ///获取用户信息
    case getCompanyConfig
    

    var path: String {
        switch self {
        case .getCompanyConfig:       return "/api/company/config"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {

        default: return nil
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-Type" : "application/json" ]
        }
    }
}

struct CommonApi {
    static func getCompanyConfig() {
        let target = ApiTarget.getCompanyConfig
        ENetworking.request(target, success: { (json) in
            GlobalConfigManager.shared.companyInfoConfig = CompanyInfoConfig(json)
        }) { (err, json) in
            
        }
    }
    
}
