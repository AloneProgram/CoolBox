//
//  BXApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    case baoxiaoList(page: Int, pageSize: Int, startDate: String, endDate: String, status: Int, sort: Int )
    
    var path: String {
        switch self {
        case .baoxiaoList:  return "/api/expense/list"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .baoxiaoList(let page, let pageSize, let startDate, let endDate, let status, let sort):
            return [
                "page": page,
                "page_size": pageSize,
                "start_date": startDate,
                "status": status,
                "sort": sort,
                "end_date": endDate
            ]
        default:
            return nil
        }
    }
}


struct BXApi {
    
    static func requestBaoxiaoList(page: Int, pageSize: Int = kPageSize, title: String = "", startDate: String = "", endDate: String = "", status: Int, sort: Int = 1, result: @escaping (BaoXiaoListModel)->Void) {
        let target = ApiTarget.baoxiaoList(page: page, pageSize: pageSize, startDate: startDate, endDate: endDate, status: status, sort: sort)
        ENetworking.request(target, success: { (json) in
            let list = BaoXiaoListModel(fromJson: json)
            result(list)
        }) { (err, json) in
            
        }
    }
}
