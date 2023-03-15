//
//  DataBase.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import MMKV
import MMKVCore

struct DataBase {
    static let shared = MMKV(mmapID: "com.immotor.huandian", mode: .singleProcess)
    static func initialize() {
        MMKV.initialize(rootDir: nil)
    }
    
    // 清除所有缓存数据
    static func clean() {
        shared?.clearAll()
    }
}

protocol ListData {
    var page: Int { get set }
    var limit: Int { get set }
    var totalCount: Int { get set }
    var totalPage: Int { get set }
//    var list: [T] { get set }
    var noMoreData: Bool { get }
}

extension ListData {
    var noMoreData: Bool {
        get {
            return page * limit >= totalCount
        }
    }
}
