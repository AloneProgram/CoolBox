//
//  SPDetailModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

struct SPDetailModel {
    
    var bxInfo: BXInfoModel?
    
    var processList: ProcessList?
    
    init(_ json: JSON) {
        bxInfo = BXInfoModel(fromJson: json)
        processList = ProcessList(json)
    }

}
