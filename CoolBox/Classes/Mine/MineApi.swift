//
//  MineApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    ///获取用户信息
    case getUserInfo
    
    //获取组织列表
    case getCompanyList
    
    //设置用户信息
    case setUserInfo(_ params: [String: Any])
    
    //修改手机号
    case changeMobile(mobile: String, vCode: String)
    
    //注销账号
    case deleteAccount
    
    //扫码登录
    case scaneLogin(_ token: String)


    var path: String {
        switch self {
        case .getUserInfo:       return "/api/user/userInfo"
        case .getCompanyList:    return "/api/user/companyList"
        case .setUserInfo:       return "/api/user/setUserInfo"
        case .changeMobile:     return "/api/user/changeMobile"
        case .deleteAccount:      return "/api/user/cancel"
        case .scaneLogin:       return "/api/user/scanLogin"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .setUserInfo(let params):
            return params
        case .changeMobile(let mobile, let vCode):
            return [
                "mobile": mobile,
                "captcha": vCode,
            ]
        case .scaneLogin(let token):
            return [
                "action": "scan_code",
                "token": token
            ]
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

struct MineApi {

    static func getUserInfo(result: @escaping (Bool)->Void) {
        let target = ApiTarget.getUserInfo
        ENetworking.request(target, success: { (json) in
            //仅更新部分资料
            let currentAcount = Login.currentAccount()
            let newInfo = Account(fromJson: json)
            currentAcount.email = newInfo.email
            currentAcount.username = newInfo.username
            currentAcount.nickname = newInfo.nickname
            currentAcount.avatarUrl = newInfo.avatarUrl
            currentAcount.mobile = newInfo.mobile
            currentAcount.type = newInfo.type
            Login.update(account: currentAcount)
            result(true)
        }) { (err, json) in
            result(false)
        }
    }
    
    static func getCompanyList(result: @escaping (CompanyListModel?)->Void) {
        ENetworking.request(ApiTarget.getCompanyList, success: { (json) in
            result(CompanyListModel(json))
        }) { _, _ in
            result(nil)
        }
    }
    
    static func updateUserInfo(params: [String: String], result: @escaping ()->Void) {
        let target = ApiTarget.setUserInfo(params)
        ENetworking.request(target, success: { (json) in
            EToast.showSuccess("资料已更新")
            result()
        }) { (err, json) in
            result()
        }
    }
    
    static func changeMobile(phone: String, vCode: String, result: @escaping ()->Void) {
        let target = ApiTarget.changeMobile(mobile: phone, vCode: vCode)
        ENetworking.request(target, success: { (json) in
            let account = Login.currentAccount()
            account.mobile = phone
            Login.update(account: account)
            EToast.showSuccess("手机号修改成功")
            result()
        }) { (err, json) in
           
        }
    }
    
    static func deleteAccount(result: @escaping (Bool)->Void) {
        let target = ApiTarget.deleteAccount
        ENetworking.request(target, success: { (json) in
            EToast.showSuccess("账号已删除")
            result(true)
        }) { (err, json) in
            
        }
    }
    
    static func scaneLogin(token: String, result: @escaping ()->Void) {
        let target = ApiTarget.scaneLogin(token)
        ENetworking.request(target, success: { (json) in
            EToast.showSuccess("扫码成功")
            result()
        }) { (err, json) in
           
        }
    }
    
}
