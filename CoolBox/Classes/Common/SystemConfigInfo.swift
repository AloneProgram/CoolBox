//
//  SystemConfigInfo.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

struct SystemConfigInfo {
    
    var openScreenAds: [String] = ["https://oss.kubaoxiao.com/launch-image/1920-1080/1.jpg",
                                   "https://oss.kubaoxiao.com/launch-image/1920-1080/2.jpg",
                                   "https://oss.kubaoxiao.com/launch-image/1920-1080/3.jpg"]
    
    var invoidceType: [String: String] = [:]
    var invoidceCatId: [String: String] = [:]
    var invoidceItemType: [String: String] = [:]
    
    var expenseType: [String: String] = [:]
    var expenseCatId: [String: String] = [:]
    var expenseVehicleType: [String: String] = [:]
    
    
    var invoidceType_keys: [String] = []
    var invoidceType_values: [String] = []

    var invoidceCatId_keys: [String] = []
    var invoidceCatId_values: [String] = []

    var invoidceItemType_keys: [String] = []
    var invoidceItemType_values: [String] = []


    var expenseType_keys: [String] = []
    var expenseType_values: [String] = []

    var expenseCatId_keys: [String] = []
    var expenseCatId_values: [String] = []

    var expenseVehicleType_keys: [String] = []
    var expenseVehicleType_values: [String] = []
    
    init(_ json: JSON) {
        openScreenAds = json["open_screen_ads"].arrayObject as? [String] ?? []
        
        invoidceType = json["invoice"]["type"].dictionaryObject as? [String: String] ?? [:]
        invoidceCatId = json["invoice"]["cat_id"].dictionaryObject as? [String: String]  ?? [:]
        invoidceItemType = json["invoice"]["item_type"].dictionaryObject as? [String: String]  ?? [:]
        
        expenseType = json["expense"]["type"].dictionaryObject as? [String: String]  ?? [:]
        expenseCatId = json["expense"]["cat_id"].dictionaryObject as? [String: String]  ?? [:]
        expenseVehicleType = json["expense"]["vehicle_type"].dictionaryObject as? [String: String]  ?? [:]
        
        
        invoidceType_keys = sortDicKeys(dic: json["invoice"]["type"].dictionaryObject)
        invoidceType_values = sortDicValues(dic: json["invoice"]["type"].dictionaryObject)
        invoidceCatId_keys = sortDicKeys(dic: json["invoice"]["cat_id"].dictionaryObject)
        invoidceCatId_values = sortDicValues(dic: json["invoice"]["cat_id"].dictionaryObject)
        invoidceItemType_keys = sortDicKeys(dic: json["invoice"]["item_type"].dictionaryObject)
        invoidceItemType_values = sortDicValues(dic: json["invoice"]["item_type"].dictionaryObject)
       
        expenseType_keys = sortDicKeys(dic: json["expense"]["type"].dictionaryObject)
        expenseType_values = sortDicValues(dic: json["expense"]["type"].dictionaryObject)
        expenseCatId_keys = sortDicKeys(dic: json["expense"]["cat_id"].dictionaryObject)
        expenseCatId_values = sortDicValues(dic: json["expense"]["cat_id"].dictionaryObject)
        expenseVehicleType_keys = sortDicKeys(dic: json["expense"]["vehicle_type"].dictionaryObject)
        expenseVehicleType_values = sortDicValues(dic: json["expense"]["vehicle_type"].dictionaryObject)

    }

}

extension SystemConfigInfo {
    func sortDicKeys(dic: [String : Any]?) -> [String]{

        var sortKeys: [String] = []
        dic?.keys.forEach({ k in
            sortKeys.append(k)
        })
        sortKeys.sort(by: {(Int($0) ?? 0) < (Int($1) ?? 0)})
        return sortKeys
    }
    
    func sortDicValues(dic: [String : Any]?) -> [String]{

        var sortKeys: [String] = []
        dic?.keys.forEach({ k in
            sortKeys.append(k)
        })
        sortKeys.sort(by: {(Int($0) ?? 0) < (Int($1) ?? 0)})
        
        var sortValues: [String] = []
        sortKeys.forEach { k in
            if let s = dic?[k] as? String  {
                sortValues.append(s)
            }
        }
        
        return sortValues
    }

}

