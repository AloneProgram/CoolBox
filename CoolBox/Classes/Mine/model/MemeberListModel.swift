//
//  MemeberListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/22.
//

import UIKit

struct MemeberListModel {

    var list: [MemberModel] = []
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        list = json.arrayValue.map({MemberModel(fromJson: $0)})
    }
}

struct MemberModel {
    var cId : String!
    var departmentId : String!
    var departmentName : String!
    var id : String!
    var invitation : String!
    var joinTime : String!
    var mobile : String!
    var name : String!
    var status : String!
    var type : String!
    var userId : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        cId = json["c_id"].stringValue
        departmentId = json["department_id"].stringValue
        departmentName = json["department_name"].stringValue
        id = json["id"].stringValue
        invitation = json["invitation"].stringValue
        joinTime = json["join_time"].stringValue
        mobile = json["mobile"].stringValue
        name = json["name"].stringValue
        status = json["status"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].stringValue
    }
}
