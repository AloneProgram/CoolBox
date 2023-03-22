//
//  DepartmentListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/22.
//

import UIKit

struct DepartmentListModel {
    var list: [DepartmentModel] = []
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        list = json.arrayValue.map({DepartmentModel(fromJson: $0)})
    }
    
}


struct DepartmentModel {
    var cId : String!
    var children : [DepartmentModel] = []
    var id : String!
    var name : String!
    var parentId : String!
    var weight : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        cId = json["c_id"].stringValue
        children = [DepartmentModel]()
        let childrenArray = json["children"].arrayValue
        for childrenJson in childrenArray{
            let value = DepartmentModel(fromJson: childrenJson)
            children.append(value)
        }
        id = json["id"].stringValue
        name = json["name"].stringValue
        parentId = json["parent_id"].stringValue
        weight = json["weight"].stringValue
    }

}
