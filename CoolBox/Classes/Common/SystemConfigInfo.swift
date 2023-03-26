//
//  SystemConfigInfo.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

struct SystemConfigInfo {
    
    var openScreenAds: [String] = []
    
    var invoidceType: [String: String] = [:]
    var invoidceCatId: [String: String] = [:]
    var invoidceItemType: [String: String] = [:]
    
    var expenseType: [String: String] = [:]
    var expenseCatId: [String: String] = [:]
    var expenseVehicleType: [String: String] = [:]
    
    init(_ json: JSON) {
        openScreenAds = json["open_screen_ads"].arrayObject as? [String] ?? []
        
        invoidceType = json["invoice"]["type"].dictionaryObject as? [String: String] ?? [:]
        invoidceCatId = json["invoice"]["cat_id"].dictionaryObject as? [String: String]  ?? [:]
        invoidceItemType = json["invoice"]["item_type"].dictionaryObject as? [String: String]  ?? [:]
       
        expenseType = json["expense"]["type"].dictionaryObject as? [String: String]  ?? [:]
        expenseCatId = json["expense"]["cat_id"].dictionaryObject as? [String: String]  ?? [:]
        expenseVehicleType = json["expense"]["vehicle_type"].dictionaryObject as? [String: String]  ?? [:]
    }

}
