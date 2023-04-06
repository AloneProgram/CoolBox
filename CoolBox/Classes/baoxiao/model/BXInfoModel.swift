//
//  BXInfoModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/6.
//

import UIKit

struct BXInfoModel {
    var createdAt = ""
    var date = ""
    var department = ""
    var id = ""
    var invoiceData : [InvoiceData] = []
    var invoiceIds = ""
    var itemType = ""
    var preGetFee = ""
    var reason = ""
    var regetFee = ""
    var returnFee = ""
    var totalFee = ""
    var travelData : [TravleData] = []
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
        id = json["id"].stringValue
        type = json["type"].stringValue
        if type == "2" { //费用报销
            invoiceData = [InvoiceData(fromJson: json["invoice_data"])]
        }else {
            invoiceData = json["invoice_data"].arrayValue.map({InvoiceData(fromJson: $0)})
        }
        
        invoiceIds = json["invoice_ids"].stringValue
        itemType = json["item_type"].stringValue
        preGetFee = json["pre_get_fee"].stringValue
        reason = json["reason"].stringValue
        regetFee = json["reget_fee"].stringValue
        returnFee = json["return_fee"].stringValue
        totalFee = json["total_fee"].stringValue
        travelData = json["travel_data"].arrayValue.map({TravleData(fromJson: $0)})

        
        userId = json["user_id"].stringValue
        username = json["username"].stringValue
    }

}

struct InvoiceData {
    var count = ""
    var fee = ""
    var list : [FapiaoDetailModel]!
    var catId = ""
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        count = json["count"].stringValue
        fee = json["fee"].stringValue
        list = [FapiaoDetailModel]()
        let listArray = json["list"].arrayValue
        for listJson in listArray{
            let value = FapiaoDetailModel(fromJson: listJson)
            list.append(value)
        }
    }
}

struct TravleData {
    var endLocation = ""
    var endTime = ""
    var expenseId = ""
    var id = ""
    var invoiceId = ""
    var isEdit = ""
    var startLocation = ""
    var startTime = ""
    var subsidyDay = ""
    var subsidyFee = ""
    var title = ""
    var userId = ""
    var vehicleType = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        endLocation = json["end_location"].stringValue
        endTime = json["end_time"].stringValue
        expenseId = json["expense_id"].stringValue
        id = json["id"].stringValue
        invoiceId = json["invoice_id"].stringValue
        isEdit = json["is_edit"].stringValue
        startLocation = json["start_location"].stringValue
        startTime = json["start_time"].stringValue
        subsidyDay = json["subsidy_day"].stringValue
        subsidyFee = json["subsidy_fee"].stringValue
        title = json["title"].stringValue
        userId = json["user_id"].stringValue
        vehicleType = json["vehicle_type"].stringValue
    }
}
