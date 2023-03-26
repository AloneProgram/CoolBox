//
//  FPApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    case fapiaoList(page: Int, pageSize: Int, title: String, startDate: String, endDate: String, status: Int, sort: Int )
    
    var path: String {
        switch self {
        case .fapiaoList:  return "/api/invoice/list"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .fapiaoList(let page, let pageSize, let title, let startDate, let endDate, let status, let sort):
            return [
                "page": page,
                "page_size": pageSize,
                "title": title,
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


struct FPApi {
    
    static func requestFapiaoList(page: Int, pageSize: Int = kPageSize, title: String = "", startDate: String = "", endDate: String = "", status: Int, sort: Int = 1, result: @escaping (FaPiaoListModel)->Void) {
        let target = ApiTarget.fapiaoList(page: page, pageSize: pageSize, title: title, startDate: startDate, endDate: endDate, status: status, sort: sort)
        ENetworking.request(target, success: { (json) in
            let list = FaPiaoListModel(fromJson: json)
            result(list)
        }) { (err, json) in
            
        }
    }
}
