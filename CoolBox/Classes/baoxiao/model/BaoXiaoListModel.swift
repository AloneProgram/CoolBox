//
//  BaoXiaoListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class BaoXiaoListModel: NSObject {

    var list: [BaoxiaoModel] = []
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        list = json.arrayValue.map({BaoxiaoModel(fromJson: $0)})
    }
}


struct BaoxiaoModel {
    var createdAt = ""
    var date = ""
    var department = ""
    var departmentId = ""
    var id = ""
    var preGetFee = ""
    var reason = ""
    var regetFee = ""
    var returnFee = ""
    var status = ""
    var totalFee = ""
    var type = ""
    var userId = ""
    var username = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        createdAt = json["created_at"].stringValue
        date = json["date"].stringValue
        department = json["department"].stringValue
        departmentId = json["department_id"].stringValue
        id = json["id"].stringValue
        preGetFee = json["pre_get_fee"].stringValue
        reason = json["reason"].stringValue
        regetFee = json["reget_fee"].stringValue
        returnFee = json["return_fee"].stringValue
        status = json["status"].stringValue
        totalFee = json["total_fee"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].stringValue
        username = json["username"].stringValue
    }

}
