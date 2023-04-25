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
    case preExpenseInvoiceDelete(fpId: String, eId: String)
    case setPreExpenseInfo(params: [String: String])
    
    case preCreateTravle(params: [String: String])
    case preSetTravleInfo(params: [String: String])
    case preDeleteTravle(tid: String, eid: String)
    
    case createExpense(preEId: String)
    case expenseInfo(eid: String)
    case deleteExpenseInvoice(fpId: String, eId: String)
    case setExpenseInfo(params: [String: String])
    case deleteExpense(eid: String)
    
    case putOutFile(eid: String)
    case deleteFile(eid: String)
    
    case subsidyConfig
    case saveSubsidyConfig(params: [String: String])
    
    case createTravle(params: [String: String])
    case setTravleInfo(params: [String: String])
    case deleteTravle(tid: String)
    
    var path: String {
        switch self {
        case .baoxiaoList:  return "/api/expense/list"
            
        case .createPreExpense:     return "/api/preExpense/create"
        case .preExpenseInfo:   return "/api/preExpense/info"
        case .preExpenseInvoiceDelete:  return "/api/preExpense/invoiceDelete"
        case .setPreExpenseInfo:        return "/api/preExpense/setInfo"
            
        case .preCreateTravle:      return "/api/preExpense/travelCreate"
        case .preSetTravleInfo:      return "/api/preExpense/travelSetInfo"
        case .preDeleteTravle:      return "/api/preExpense/travelDelete"
            
        case .createExpense:      return "/api/expense/create"
        case .expenseInfo:      return "/api/expense/info"
        case .deleteExpenseInvoice:         return "/api/expense/invoiceDelete"
        case .setExpenseInfo:        return "/api/expense/setInfo"
        case .deleteExpense:        return "/api/expense/delInfo"
            
        case .putOutFile:      return "/api/expense/putoutFile"
        case .deleteFile:       return "/api/expense/deleteFile"
        case .subsidyConfig:      return "/api/expense/config"
        case .saveSubsidyConfig:        return "/api/expense/saveTravelSubsidySetting"
        
        case .createTravle:      return "/api/expense/travelCreate"
        case .setTravleInfo:      return "/api/expense/travelSetInfo"
        case .deleteTravle:      return "/api/expense/travelDelete"
            
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

        case .preExpenseInvoiceDelete(let fpId, let eId):
            return [
                "invoice_id": fpId,
                "expense_id": eId
            ]
        case .setPreExpenseInfo(let params):
            return params
            
            
        case .createExpense(let preEId):
            return [
                "expense_id": preEId
            ]
        case .expenseInfo(let eId):
            return [
                "expense_id": eId
            ]
        case .deleteExpenseInvoice(let fpId, let eId):
            return [
                "invoice_id": fpId,
                "expense_id": eId
            ]
        case .setExpenseInfo(let params):
            return params
        case .deleteExpense(let eid):
            return [
                "expense_id": eid
            ]
            
        case .putOutFile(let eid):
            return [
                "expense_id": eid
            ]
        case .deleteFile(let eid):
            return [
                "expense_id": eid
            ]

        case .saveSubsidyConfig(let params):
            return params
      
        case .preDeleteTravle(let tid, let eid):
            return [
                "travel_id": tid,
                "expense_id": eid
            ]
            
        case .deleteTravle(let tid):
            return [
                "travel_id": tid
            ]
        case .preCreateTravle(let params):
            return params
        case .createTravle(let params):
            return params
            
        case .preSetTravleInfo(let params):
            return params
        case .setTravleInfo(let params):
            return params
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
    
    // 删除报销单/预报销单发票
    static func deleteExpenseFP(isPre: Bool, fpid: String, eid: String, result: @escaping (Bool)->Void) {
        let target = isPre ? ApiTarget.preExpenseInvoiceDelete(fpId: fpid, eId: eid) : ApiTarget.deleteExpenseInvoice(fpId: fpid, eId: eid)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
    
    // 编辑报销单/预报销单
    static func setExpenseInfo(isPre: Bool, params: [String: String], result: @escaping (Bool)->Void) {
        let target = isPre ? ApiTarget.setPreExpenseInfo(params: params) : ApiTarget.setExpenseInfo(params: params)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }

    static func createExpenseRequest(eid: String, result: @escaping (String)->Void) {
        let target = ApiTarget.createExpense(preEId: eid)
        ENetworking.request(target, success: { (json) in
            result(json["expense_id"].stringValue)
        }) { (err, json) in
        }
    }
    
    
    static func getExpenseInfo(eid: String, result: @escaping (BXInfoModel)->Void) {
        let target = ApiTarget.expenseInfo(eid: eid)
        ENetworking.request(target, success: { (json) in
            result(BXInfoModel(fromJson: json))
        }) { (err, json) in
        }
    }
    
    static func deleteBX(eid: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.deleteExpense(eid: eid)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
    
    static func createPDFFile(eid: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.putOutFile(eid: eid)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(true)
        }) { (err, json) in
            EHUD.dismiss()
        }
    }
    
    static func deletePDFFile(eid: String) {
        let target = ApiTarget.deleteFile(eid: eid)
        ENetworking.request(target, success: { (json) in
            
        }) { (err, json) in
           
        }
    }
    
    
    static func getSubsidyConfig(result: @escaping (SubsidyConfig)->Void) {
        let target = ApiTarget.subsidyConfig
        ENetworking.request(target, success: { (json) in
            result(SubsidyConfig(fromJson: json))
        }) { (err, json) in
        }
    }
    
    static func saveSubsidyConfig(params: [String: String], result: @escaping (Bool)->Void) {
        let target = ApiTarget.saveSubsidyConfig(params: params)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
    
    static func createTravel(isPre: Bool, params: [String: String], result: @escaping (String)->Void) {
        let target = isPre ? ApiTarget.preCreateTravle(params: params) : ApiTarget.createTravle(params: params)
        ENetworking.request(target, success: { (json) in
            result(json["travel_id"].stringValue)
        }) { (err, json) in
        }
    }
    
    static func setTravelInfo(isPre: Bool, params: [String: String], result: @escaping (Bool)->Void) {
        let target = isPre ? ApiTarget.preSetTravleInfo(params: params) : ApiTarget.setTravleInfo(params: params)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
    
    static func deleteTravel(isPre: Bool, tid: String, eid: String, result: @escaping (Bool)->Void) {
        let target = isPre ? ApiTarget.preDeleteTravle(tid: tid, eid: eid) : ApiTarget.deleteTravle(tid: tid)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
}
