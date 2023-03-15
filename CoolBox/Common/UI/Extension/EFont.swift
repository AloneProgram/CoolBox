//
//  EFont.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

/// 正常体
func Font(_ size : CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
}

/// 粗体
func BoldFont(_ size : CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: size)
}

/// 半粗体
func Semibold(_ size : CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: .semibold)
}

/// 细体
func LightFont(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: .light)
}

/// 中间体
func MediumFont(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: .medium)
}

//-------PingFangSC
///正常体
func SCFont(_ size: CGFloat) -> UIFont {
    return UIFont(name: "PingFangSC-Regular", size: size) ?? Font(size)
}

///中黑体
func SCMediumFont(_ size: CGFloat) -> UIFont {
    return UIFont(name: "PingFangSC-Medium", size: size) ?? MediumFont(size)
}
