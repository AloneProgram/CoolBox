//
//  CompanyListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

struct CompanyListModel {
    var list: [CompanyModel] = []

    init(_ json: JSON) {
        list = json.arrayValue.map({CompanyModel(fromJson: $0)})
    }
}


struct CompanyModel {
    var companyId : String!
    var companyName : String!
    var isDefault: Bool = false
    var joinTime : String!
    var memberType : String!
    var name : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        companyId = json["company_id"].stringValue
        companyName = json["company_name"].stringValue
        isDefault = json["is_default"].stringValue == "1"
        joinTime = json["join_time"].stringValue
        memberType = json["member_type"].stringValue
        name = json["name"].stringValue
    }

}
