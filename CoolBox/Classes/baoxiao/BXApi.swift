//
//  BXApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    case baoxiaoList(page: Int, pageSize: Int, startDate: String, endDate: String, status: Int, sort: Int )
    
    case createPreExpense(invoiceIds: String, type: String)
    
    case preExpenseInfo(eId: String)
    
    case expenseInfo(eid: String)
    
    var path: String {
        switch self {
        case .baoxiaoList:  return "/api/expense/list"
        case .createPreExpense:     return "/api/preExpense/create"
        case .preExpenseInfo:   return "/api/preExpense/info"
        case .expenseInfo:      return "/api/expense/info"
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
        case .createPreExpense(let invoiceIds, let type):
            return [
                "invoice_ids": invoiceIds,
                "type": type
            ]
        case .preExpenseInfo(let eId):
            return [
                "expense_id": eId
            ]
        case .expenseInfo(let eId):
            return [
                "expense_id": eId
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
    
    static func createPreExpenseRequest(invoiceIds: String, type: String, result: @escaping (String)->Void) {
        let target = ApiTarget.createPreExpense(invoiceIds: invoiceIds, type: type)
        ENetworking.request(target, success: { (json) in
            result(json["expense_id"].stringValue)
        }) { (err, json) in
        }
    }
    
    static func getPreExpenseInfo(eid: String, result: @escaping (BXInfoModel)->Void) {
        let target = ApiTarget.preExpenseInfo(eId: eid)
        ENetworking.request(target, success: { (json) in
            result(BXInfoModel(fromJson: json))
        }) { (err, json) in
        }
    }
    
    static func getExpenseInfo(eid: String, result: @escaping (BXInfoModel)->Void) {
        let target = ApiTarget.expenseInfo(eId: eid)
        ENetworking.request(target, success: { (json) in
            result(BXInfoModel(fromJson: json))
        }) { (err, json) in
        }
    }
}
