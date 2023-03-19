//
//  CommonInfoModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

class CommonInfoModel: NSObject {

    var leftLcon: UIImage?
    var leftText = ""
    var rightText = ""
    var rightTextColor = UIColor(hexString: "#86909C")
    var showRightArrow = false
    var showRightImageView = false
    var rightImageUrl: String?
    var rightPaddingText: String = ""
    var rightPaddingStyle: PaddingLabelStyle = .none
    
    init(_ leftLcon: UIImage? = nil,
         leftText: String,
         rightText: String = "",
         rightTextColor:UIColor = UIColor(hexString: "#86909C"),
         showRightArrow: Bool = false,
         showRightImageView: Bool = false,
         rightImageUrl: String = "",
         rightPaddingText: String = "",
         rightPaddingStyle: PaddingLabelStyle = .none)
    {
        self.leftLcon = leftLcon
        self.leftText = leftText
        self.rightText = rightText
        self.rightTextColor = rightTextColor
        self.showRightArrow = showRightArrow
        self.showRightImageView = showRightImageView
        self.rightImageUrl = rightImageUrl
        self.rightPaddingText = rightPaddingText
        self.rightPaddingStyle =  rightPaddingStyle
    }
    
}
