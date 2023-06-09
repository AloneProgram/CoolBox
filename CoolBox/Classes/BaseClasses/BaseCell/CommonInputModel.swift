//
//  CommonInputModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class CommonInputModel: NSObject {
    
    var showRedPoint = true
    var leftText = ""
    var canInput = true
    var tfPlaceHolder = ""
    var tfText = ""
    var tfType: UIKeyboardType = .default
    var showBtn = false
    var btnTitlte = ""
    var showLine = true
    var bottomLineHeight: CGFloat = 0.5
    
    init(showRedPoint: Bool = true,
         leftText: String = "",
         canInput: Bool = true,
         tfPlaceHolder: String = "",
         tfText: String = "",
         tfType: UIKeyboardType = .default,
         showBtn: Bool = false,
         btnTitlte: String = "",
         showLine: Bool = true,
         bottomLineHeight: CGFloat = 0)
    {
        self.showRedPoint = showRedPoint
        self.leftText = leftText
        self.canInput = canInput
        self.tfPlaceHolder = tfPlaceHolder
        self.tfText = tfText
        self.tfType = tfType
        self.showBtn = showBtn
        self.btnTitlte = btnTitlte
        self.showLine = showLine
        self.bottomLineHeight = bottomLineHeight
    }

}
