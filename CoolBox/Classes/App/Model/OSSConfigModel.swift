//
//  OSSConfigModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

struct OSSConfigModel {
    var key : String!
    var token : String!
    var url : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        key = json["key"].stringValue
        token = json["token"].stringValue
        url = json["url"].stringValue
    }
}
