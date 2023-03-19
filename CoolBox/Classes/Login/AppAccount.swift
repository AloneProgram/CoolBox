//
//  AppAccount.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

struct Login {
        /// 初始化，包括 第三方 自动登录
    static func `do`() {
       //TODO:
    }
    
    static func isLogged() -> Bool {
        if Login.authorization() != nil {
            return true
        }
        return false
    }
    
    static func authorization() -> String? {
        let acc = Account.share
        guard let token = acc.token else { return nil }
        return token

    }
    
    static func currentAccount() -> Account {
        return Account.share
    }
    
    static func userId() -> String? {
        return Account.share.userId
    }
    
    
    static func logout() {
        Account.share.clear()
        AccountData.remove()
        EApiConfig.updateApp(authorization: nil)
    }
    
    static func update(account: Account) {
        Account.share.update(account: account)
        AccountData.save(Account.share)
        EApiConfig.updateApp(authorization: authorization())
    }
    
    fileprivate static func getAccount() -> Account {
        guard let json = AccountData.get() else {
            return Account()
        }
        return Account(fromJson: json)
    }
}

class Account {
    
    fileprivate static var share: Account {
        class singleton {
            static let instance: Account = Login.getAccount()
        }
        let instance = singleton.instance
        
        DispatchQueue.once(token: "needlogin") {
            NotificationCenter.default.addObserver(instance,
                                                   selector: #selector(Account.needLogin(_:)),
                                                   name: AppNeedLoginNotificationKey,
                                                   object: nil)
         }

        return instance
    }
    
    var avatarUrl = ""
    var email = ""
    var userId = ""
    var joinTime = ""
    var loginTime = ""
    var mobile = ""
    var nickname = ""
    var refreshTime = ""
    var refreshTimestamp = ""
    var token: String?
    var uid = ""
    var username = ""
    //用户类型 1个人 2企业
    var type = ""
    var companyId = ""
    var companyName = ""
    var isCompanyAdmin = false
    
    var containsStart: Bool {
        return nickname.contains("****")
    }
    
    //有些地方使用nickname需要判断是否包含****, 包含则说明昵称未被修改,不可直接使用
    var usedNickName: String {
        return containsStart ? "" : nickname
    }
  
    init(fromJson json: JSON? = nil){
        guard let json = json else { return }
        avatarUrl = json["avatar_url"].stringValue
        email = json["email"].stringValue
        userId = json["id"].stringValue
        joinTime = json["join_time"].stringValue
        loginTime = json["login_time"].stringValue
        mobile = json["mobile"].stringValue
        nickname = json["nickname"].stringValue
        refreshTime = json["refresh_time"].stringValue
        refreshTimestamp = json["refresh_timestamp"].stringValue
        token = json["token"].stringValue
        uid = json["uid"].stringValue
        username = json["username"].stringValue
        type = json["type"].stringValue
        companyId = json["company_id"].stringValue
        companyName = json["company_name"].stringValue
        isCompanyAdmin = json["is_company_admin"].intValue == 3

    }
    
    fileprivate func toJson() -> JSON {
        var json = JSON()
        json["avatar_url"].string = avatarUrl
        json["email"].string = email
        json["id"].string = userId
        json["join_time"].string = joinTime
        json["mobile"].string = mobile
        json["nickname"].string = nickname
        json["refresh_time"].string = refreshTime
        json["refresh_timestamp"].string = refreshTimestamp
        json["token"].string = token
        json["uid"].string = uid
        json["username"].string = username
        json["type"].string = type
        json["companyId"].string = companyId
        json["companyName"].string = companyName
        json["isCompanyAdmin"].string = isCompanyAdmin ? "3" : "1"
        
        return json
    }
    
    fileprivate func clear() {
        avatarUrl = ""
        email = ""
        userId = ""
        joinTime = ""
        mobile = ""
        nickname = ""
        refreshTime = ""
        refreshTimestamp = ""
        token = nil
        uid = ""
        username = ""
        type = ""
        companyId = ""
        companyName = ""
        isCompanyAdmin = false
    }
    
    fileprivate func update(account: Account) {

        avatarUrl = account.avatarUrl
        email = account.email
        userId = account.userId
        joinTime = account.joinTime
        mobile = account.mobile
        nickname = account.nickname
        refreshTime = account.refreshTime
        refreshTimestamp = account.refreshTimestamp
        token = account.token
        uid = account.uid
        username = account.username
        type = account.type
        companyId = account.companyId
        companyName = account.companyName
        isCompanyAdmin = account.isCompanyAdmin
    }
    
    @objc fileprivate func needLogin(_ noti: NSNotification) {
        Login.logout()
        let keyWindow = UIApplication.shared.delegate?.window
        keyWindow??.rootViewController = LoginVC()
    }
}

// MARK: - 数据持久化
// 用户信息
private struct AccountData {
    static func save(_ data: Account) {
        let json = data.toJson().description
        DataBase.shared?.set(json, forKey: "app_userInfo")
    }
    
    static func get() -> JSON? {
        guard let string = DataBase.shared?.string(forKey: "app_userInfo") else { return nil }
        return JSON(parseJSON: string)
    }
    
    static func remove() {
        DataBase.shared?.removeValue(forKey: "app_userInfo")
    }
}
