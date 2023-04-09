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
    
    case processLit
    
    case spInfo(exId: String)
    
    case createSP(cid: String, eId: String, processData: String)
    
    case delSP(exId: String)
    
    case processInfo(cid: String)
    case setProcessInfo(params: [String: String])
    
    var path: String {
        switch self {
        case .mySPDList:  return "/api/examine/list"
        case .mySendSPDList:        return "/api/examine/myList"
        case .handleSPD:            return "/api/examine/examine"
        case .processLit:       return "/api/examine/processList"
        case .spInfo:       return "/api/examine/info"
        case .createSP:     return "/api/examine/create"
        case .delSP:        return "/api/examine/delInfo"
        case .processInfo:  return "/api/company/settinginfo"
        case .setProcessInfo:       return "/api/company/setSettinginfo"
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
        case .spInfo(let exId):
            return [
                "examine_id": exId
            ]
        case .createSP(let cid, let eId, let processData):
            return [
                "c_id": cid,
                "expense_id": eId,
                "process_data": processData,
            ]
        case .delSP(let exId):
            return [
                "examine_id": exId
            ]
        case .processInfo(let cid):
            return [
                "c_id": cid
            ]
        case .setProcessInfo(let params):
            return params
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
    
    static func getProcessList( result: @escaping (ProcessList)->Void) {
        let target = ApiTarget.processLit
        ENetworking.request(target, success: { (json) in
            result(ProcessList(json))
        }) { (err, json) in
            
        }
    }
    
    static func getSPInfo(exId: String,result: @escaping (SPDetailModel)->Void) {
        let target = ApiTarget.spInfo(exId: exId)
        ENetworking.request(target, success: { (json) in
            result(SPDetailModel(json))
        }) { (err, json) in
            
        }
    }
    
    static func createSP(cid: String, eid: String, processStr: String, result: @escaping (String)->Void) {
        let target = ApiTarget.createSP(cid: cid, eId: eid, processData: processStr)
        ENetworking.request(target, success: { (json) in
            result(json.stringValue)
        }) { (err, json) in
            
        }
    }
    
    
    static func deleteSP(exid: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.spInfo(exId: exid)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
    
    static func getProcessInfo(cid: String, result: @escaping (ProcessNode)->Void) {
        let target = ApiTarget.processInfo(cid: cid)
        ENetworking.request(target, success: { (json) in
            result(ProcessNode(fromJson: json))
        }) { (err, json) in
            
        }
    }
    
    static func setProcessInfo(params: [String: String], result: @escaping (Bool)->Void) {
        let target = ApiTarget.setProcessInfo(params: params)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
}
