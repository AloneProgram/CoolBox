//
//  CompanyConfig.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

struct CompanyInfoConfig {
    
    var industryList: [CompanyInfoModel] = []
    var staffTypeList: [CompanyInfoModel] = []
    
    init(_ json: JSON) {
        industryList = json["industry_list"].arrayValue.map({CompanyInfoModel($0)})
        staffTypeList = json["staff_type_list"].arrayValue.map({CompanyInfoModel($0)})
    }

}


struct CompanyInfoModel {
    var id = ""
    var name = ""
    var children: [CompanyInfoModel] = []
    
    init(_ json: JSON) {
        id = json["json"].stringValue
        name = json["name"].stringValue
        children = json["children"].arrayValue.map({CompanyInfoModel($0)})
    }
}
