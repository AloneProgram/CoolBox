//
//  SPListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

struct SPListModel {
    
    var list: [SPModel] = []
    //(我的待审批,大于0显示红点)
    var count = 0
    //我发起的(大于0显示红点)
    var unreadCount = 0

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        
        list = json["data"].arrayValue.map({SPModel(fromJson: $0)})
        count = json["count"].intValue
        unreadCount = json["unread_count"].intValue
    }
}


struct SPModel {
    var cId  = ""
    var createdAt  = ""
    var date  = ""
    var department  = ""
    var departmentId  = ""
    var examineId  = ""
    var expenseId  = ""
    var id  = ""
    var itemType  = ""
    var pdfUrl  = ""
    var preGetFee  = ""
    var reason  = ""
    var regetFee  = ""
    var returnFee  = ""
    var status  = ""
    var totalFee  = ""
    var type  = ""
    var updatedAt  = ""
    var userId  = ""
    var username  = ""
    
    var isRead = true


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        cId = json["c_id"].stringValue
        createdAt = json["created_at"].stringValue
        date = json["date"].stringValue
        department = json["department"].stringValue
        departmentId = json["department_id"].stringValue
        examineId = json["examine_id"].stringValue
        expenseId = json["expense_id"].stringValue
        id = json["id"].stringValue
        itemType = json["item_type"].stringValue
        pdfUrl = json["pdf_url"].stringValue
        preGetFee = json["pre_get_fee"].stringValue
        reason = json["reason"].stringValue
        regetFee = json["reget_fee"].stringValue
        returnFee = json["return_fee"].stringValue
        status = json["status"].stringValue
        totalFee = json["total_fee"].stringValue
        type = json["type"].stringValue
        updatedAt = json["updated_at"].stringValue
        userId = json["user_id"].stringValue
        username = json["username"].stringValue
        
        isRead = json["is_read"].intValue == 1
    }
}
