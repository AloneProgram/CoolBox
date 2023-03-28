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
    
    var path: String {
        switch self {
        case .fapiaoList:  return "/api/invoice/list"
        case .scanImport:   return "/api/invoice/qrcodeScan"
        case .takePhotoImport:      return "/api/invoice/cameraScan"
        case .invoiceImport:        return "/api/invoice/import"
        case .deleteFapiao:        return "/api/invoice/delInfo"
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
            result(false)
        }
    }
    
    static func takePhotoImport(data: Data, imgUrl: String, result: @escaping (CameraImportFaPiaoList)->Void) {
        let target = ApiTarget.takePhotoImport(image: data.base64EncodedString(), imgUrl: imgUrl)
        ENetworking.request(target, success: { (json) in
            EHUD.dismiss()
            result(CameraImportFaPiaoList(fromJson: json))
        }) { (err, json) in
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
}
