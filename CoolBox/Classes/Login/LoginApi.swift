//
//  LoginApi.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/16.
//

import UIKit

fileprivate enum ApiTarget: ETargetType {
    
    //----手机号登录-----
    ///获取验证码
    case getSmsCode(userPhone: String, type: Int)
    ///手机号登录
    case phoneLogin(userPhone: String, checkCode: String)
    ///退出登录
    case logout
    
    //获取配置信息
    case getOSSConfig
    

    var path: String {
        switch self {
        case .getSmsCode:       return "/api/user/sendCaptcha"
        case .phoneLogin:       return "/api/user/login"
        case .logout:           return "/api/user/logout"
        case .getOSSConfig:     return "/api/system/getOssConfig"
        }
    }
    
    var method: Method {
        switch self {
        default: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getSmsCode(let userPhone, let type):
            return ["mobile": userPhone, "type": type]
        case .phoneLogin(let userPhone, let checkCode):
            return [
                "mobile": userPhone,
                "captcha": checkCode
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

struct LoginApi {
    ///获取验证码
    static func getSmsCode(phone: String, type: Int = 1, result: @escaping (_ data: Bool) -> Void) {
        let target = ApiTarget.getSmsCode(userPhone: phone, type: type)
        ENetworking.request(target, success: { (response) in
            EToast.showSuccess("验证码发送成功")
            result(true)
        }) { (error, info) in
            result(false)
        }
    }
    
    ///手机号登录
    static func phoneLogin(phone: String, smsCode: String, result: @escaping (Bool)->Void) {
        let target = ApiTarget.phoneLogin(userPhone: phone, checkCode: smsCode)
        ENetworking.request(target, success: { (json) in
            Login.update(account: Account(fromJson: json))
            EToast.showSuccess("登录成功")
            result(true)
        }) { (err, json) in
            result(false)
        }
    }
    
    
    ///退出登录
    static func logout(_ result: @escaping (Bool)->Void) {
        let target = ApiTarget.logout
        ENetworking.request(target, success: { (response) in
            result(true)
        }) { (error, info) in
            result(false)
        }
    }
    
    //获取OSS配置
    static func getOSSConfig(_ result: @escaping (OSSConfigModel?)->Void) {
        ENetworking.request(ApiTarget.getOSSConfig, success: { (response) in
            result(OSSConfigModel(fromJson: response))
        }) { (error, info) in
            result(nil)
        }
    }
}
