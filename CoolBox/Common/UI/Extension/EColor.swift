//
//  EColor.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 整数位色值 255，255，255 R=G=B
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(redInt: rgb, greenInt: rgb, blueInt: rgb, alpha: alpha)
    }
    
    /// 整数位色值 255，255，255
    convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat = 1.0) {
        let newRed = CGFloat(redInt) / 255.0
        let newGreen = CGFloat(greenInt) / 255.0
        let newBlue = CGFloat(blueInt) / 255.0
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
    
    /// 16进制色值 0xFF00FF
    convenience init(hexValue: UInt, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(hexValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    /// 16进制色值 "#FF00FF"
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let cString = hexString.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()
        
        let scanner = Scanner(string: cString)
        if cString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        else {
            fatalError("UIColor hexString must be such as #FF00FF")
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: alpha)
    }
    
    var image: UIImage? {
        get { return image() }
    }
    
    /// 颜色值生成图片
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        var resultImage: UIImage? = nil
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return resultImage }
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}

/**
 * App appearance
 * 应用内的颜色都用这里类来提供
 */
class EColor: UIColor {
    
    /** 主题色 - #265DFF */
    @objc public static var themeColor: UIColor {
        get {
            return UIColor(hexString: "#FF7513")
        }
    }
    
    /** 协议高亮色 - 255 242 0 */
    @objc public static var protocolColor: UIColor {
        get {
            return UIColor(redInt: 255, greenInt: 242, blueInt: 0)
        }
    }
    
    /** 禁止 置灰 #CCCCCC */
    @objc public static var disableColor: UIColor {
        get {
            return UIColor(hexString: "#E7E8EA")
        }
    }
    
    /** 页面背景 - #FFFFFF */
    @objc public static var viewBgColor: UIColor {
        get {
            return UIColor(hexString: "#FFFFFF")
        }
    }
    
    /** 子控件背景 - #F4F4F9 */
    @objc public static var widgetBgColor: UIColor {
        get {
            return UIColor(hexString: "#F4F4F9")
        }
    }
    
    /** 分割线 #E6E6E6 */
    @objc public static var lineColor: UIColor {
        get {
            return UIColor(hexString: "#FF6B00")
        }
    }
    
    /** 黑色文字颜色 - #333333 */
    @objc public static var blackTextColor: UIColor {
        get {
            return UIColor(hexString: "#333333")
        }
    }
    
    /// 未读消息数角标颜色 - 255 88 88
    @objc public static var badgeColor: UIColor {
        get {
            return UIColor(redInt: 255, greenInt: 88, blueInt: 88)
        }
    }
    
    /// 深色文本 - 51 51 51
    @objc public static var darkGrayText: UIColor {
        get {
            return  UIColor(rgb: 51)
        }
    }
}
