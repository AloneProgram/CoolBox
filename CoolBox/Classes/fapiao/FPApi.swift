//
//  FPApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    case fapiaoList(page: Int, pageSize: Int, title: String, startDate: String, endDate: String, status: Int, sort: Int )
    
    case scanImport(qrCodeStr: String)
    case takePhotoImport(image: String, imgUrl: String)
    
    case invoiceImport(ids: String)
    
    case deleteFapiao(ids: String)
    
    case setFPStatus(ids: String, status: Int)
    
    case aliImport(token: String)
    
    case wxImport(cardArrStr: String)
    
    case getWxTickt
    
    case emmailImport
    
    case fpInfo(id: String)
    
    case setFPFile(fileUrl: String, id: String)
    
    case saveFapiao(params: [String: Any])
    
    var path: String {
        switch self {
        case .fapiaoList:  return "/api/invoice/list"
        case .scanImport:   return "/api/invoice/qrcodeScan"
        case .takePhotoImport:      return "/api/invoice/cameraScan"
        case .invoiceImport:        return "/api/invoice/import"
        case .deleteFapiao:        return "/api/invoice/delInfo"
        case .setFPStatus:              return "/api/invoice/setStatus"
        case .aliImport:            return "/api/invoice/alipayImport"
        case .getWxTickt:              return "/api/system/getWxTicketConfig"
        case .wxImport:         return "/api/invoice/wechatImport"
        case .emmailImport:     return "/api/invoice/mailImport"
        case .fpInfo:       return "/api/invoice/info"
        case .setFPFile:      return "/api/invoice/setFileUrl"
        case .saveFapiao:       return "/api/invoice/setInfo"
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
        case .scanImport(let qrCodeStr):
            return [
                "qrcode_str" : qrCodeStr
            ]
        case .takePhotoImport(let data, let imgUrl):
            return [
                "img": data,
                "img_url": imgUrl
            ]
        case .invoiceImport(let ids):
            return [
                "invoice_ids": ids
            ]
        case .deleteFapiao(let ids):
            return [
                "invoice_ids": ids
            ]
        case .setFPStatus(let ids, let status):
            return [
                "status": status,
                "invoice_ids": ids
            ]
        case .aliImport(let token):
            return ["invoice_token": token]
        case .wxImport(let cardArrStr):
            return [
                "card_data": cardArrStr
            ]
        case .fpInfo(let id):
            return [
                "invoice_id" : id
            ]
        case .setFPFile(let fileUrl, let id):
            return [
                "invoice_id": id,
                "file_url": fileUrl
            ]
        case .saveFapiao(let params):
            return params
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
    
    static func scanImport(qeCodeStr: String, result: @escaping (Bool)->Void) {
        EHUD.show("识别中..")
        let target = ApiTarget.scanImport(qrCodeStr: qeCodeStr)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(true)
        }) { (err, json) in
            EHUD.dismiss()
            result(false)
        }
    }
    
    static func takePhotoImport(data: Data, imgUrl: String, result: @escaping (CameraImportFaPiaoList)->Void) {
        let target = ApiTarget.takePhotoImport(image: data.base64EncodedString(), imgUrl: imgUrl)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(CameraImportFaPiaoList(fromJson: json))
        }) { (err, json) in
            EHUD.dismiss()
//            EToast.showFailed("照片识别失败")
        }
    }
    
    static func invoiceImport(idsStr: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.invoiceImport(ids: idsStr)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
    
    static func deleteFP(idsStr: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.deleteFapiao(ids: idsStr)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
        }
    }
    
    static func setFPStatus(idsStr: String, status: Int = 5, result: @escaping (Bool)->Void) {
        let target = ApiTarget.setFPStatus(ids: idsStr, status: status)
        ENetworking.request(target, success: { (json) in
            EToast.showSuccess("发票状态修改成功")
            result(true)
        }) { (err, json) in
        }
    }
    
    static func aliImportFP(token: String, result: @escaping  (CameraImportFaPiaoList)->Void) {
        let target = ApiTarget.aliImport(token: token)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(CameraImportFaPiaoList(fromJson: json))
        }) { (err, json) in
            EHUD.dismiss()
        }
    }
    
    static func getWxTiket(result: @escaping (String)->Void) {
        let target = ApiTarget.getWxTickt
        ENetworking.request(target, success: { (json) in
            result(json.stringValue)
        }) { (err, json) in
            EHUD.dismiss()
        }
    }
    
    static func wxImportFP(arrStr: String, result: @escaping (CameraImportFaPiaoList)->Void) {
        let target = ApiTarget.wxImport(cardArrStr: arrStr)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(CameraImportFaPiaoList(fromJson: json))
        }) { (err, json) in
            EHUD.dismiss()
        }
    }
    
    static func emialImport(result: @escaping (CameraImportFaPiaoList)->Void) {
        let target = ApiTarget.emmailImport
        ENetworking.request(target, success: { (json) in
            result(CameraImportFaPiaoList(fromJson: json))
        }) { (err, json) in
        }
    }
    
    static func fapioaInfo(id: String, result: @escaping (FapiaoDetailModel)->Void) {
        let target = ApiTarget.fpInfo(id: id)
        ENetworking.request(target, success: { (json) in
            result(FapiaoDetailModel(fromJson: json))
        }) { (err, json) in
        }
    }
    
    static func setFPFile(id: String, fileUrl: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.setFPFile(fileUrl: fileUrl, id: id)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
    
    static func saveInfo(params: [String: Any], result: @escaping (Bool)->Void) {
        let target = ApiTarget.saveFapiao(params: params)
        ENetworking.request(target, success: { (json) in
            result(true)
        }) { (err, json) in
            
        }
    }
}
