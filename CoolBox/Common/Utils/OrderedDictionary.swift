//
//  OrderedDictionary.swift
//  Livepush
//
//  Created by winter on 2020/4/26.
//  Copyright © 2020 yeting. All rights reserved.
//

import Foundation

extension Dictionary {
    func sortedJsonString() -> String {
        guard let tempDic = self as? Dictionary<String,Any> else {
            return ""
        }
        
        var keys = Array<String>()
        for key in tempDic.keys {
            keys.append(key)
        }
        keys.sort { $0 < $1 }
        var signString = "{"
        var arr: Array<String> = []
        for key in keys {
            let value = tempDic[key]
            if let value = value as? Dictionary<String,Any> {
                arr.append("\"\(key)\":\(value.sortedJsonString())")
            }
            else if let value = value as? Array<Any> {
                arr.append("\"\(key)\":\(value.sortedJsonString())")
            }
            else {
                guard let value = tempDic[key] else {
                    arr.append("\"\(key)\": \"\"")
                    continue
                }
                if let t = value as? String {
                    arr.append("\"\(key)\":\"\(t)\"")
                }
                else {
                    arr.append("\"\(key)\":\(value)")
                }
            }
        }
        signString += arr.joined(separator: ",")
        signString += "}"
        return signString
    }
}

extension Array {
    func  sortedJsonString() -> String {
        let array = self
        var arr: Array<String> = []
        var signString = "["
        for value in array {
            if let value = value as? Dictionary<String,Any> {
                arr.append(value.sortedJsonString())
            }
            else if let value = value as? Array<Any> {
                arr.append(value.sortedJsonString())
            }
            else {
                if let t = value as? String {
                    arr.append("\"\(t)\"")
                }
                else {
                    arr.append("\(value)")
                }
            }
        }
        arr.sort { $0 < $1 }
        signString += arr.joined(separator: ",")
        signString += "]"
        return signString
    }
}
