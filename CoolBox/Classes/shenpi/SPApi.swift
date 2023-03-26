//
//  SPApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    case mySPDList(page: Int, pageSize: Int, startDate: String, endDate: String, status: Int, sort: Int )
    
    case mySendSPDList(page: Int, pageSize: Int, startDate: String, endDate: String, sort: Int )
    
    case handleSPD(status: Int, id: String, reason: String)
    
    var path: String {
        switch self {
        case .mySPDList:  return "/api/examine/list"
        case .mySendSPDList:        return "/api/examine/myList"
        case .handleSPD:            return "/api/examine/examine"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .mySPDList(let page, let pageSize, let startDate, let endDate, let status, let sort):
            return [
                "page": page,
                "page_size": pageSize,
                "start_date": startDate,
                "status": status,
                "sort": sort,
                "end_date": endDate
            ]
        case .mySendSPDList(let page, let pageSize, let startDate, let endDate, let sort):
            return [
                "page": page,
                "page_size": pageSize,
                "start_date": startDate,
                "sort": sort,
                "end_date": endDate
            ]
            
        case .handleSPD(let status, let id, let reason):
            return [
                "examine_id": id,
                "status": status,
                "reason": reason
            ]
        default:
            return nil
        }
    }
}


struct SPApi {
    
    static func requestMySPDList(page: Int, pageSize: Int = kPageSize, startDate: String = "", endDate: String = "", status: Int, sort: Int = 1, result: @escaping (SPListModel)->Void) {
        let target = ApiTarget.mySPDList(page: page, pageSize: pageSize, startDate: startDate, endDate: endDate, status: status, sort: sort)
        ENetworking.request(target, success: { (json) in
            let list = SPListModel(fromJson: json)
            result(list)
        }) { (err, json) in
            
        }
    }
    
    static func requestMySendSPDList(page: Int, pageSize: Int = kPageSize, startDate: String = "", endDate: String = "", sort: Int = 1, result: @escaping (SPListModel)->Void) {
        let target = ApiTarget.mySendSPDList(page: page, pageSize: pageSize, startDate: startDate, endDate: endDate, sort: sort)
        ENetworking.request(target, success: { (json) in
            let list = SPListModel(fromJson: json)
            result(list)
        }) { (err, json) in
            
        }
    }
    
    static func handleSPD(id: String, status: Int, reson: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.handleSPD(status: status, id: id, reason: reson)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
}
