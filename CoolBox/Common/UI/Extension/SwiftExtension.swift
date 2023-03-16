//
//  SwiftExtension.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import UIKit

// MARK: - StringExtension
extension String {
        
    var length: Int {
        ///更改成其他的影响含有emoji协议的签名
        return self.utf16.count
    }
    
    /// 根据开始位置和长度截取字符串
    func subString(start:Int = 0, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        
        let attributeString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        let str = attributeString.string
        let st = str.index(startIndex, offsetBy:start)
        let en = str.index(st, offsetBy:len)
        return String(str[st ..< en])
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat{
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height:height)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.width
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

///取字符串中数字
extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self {
        return filter(("0"..."9").contains)
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()

    public class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }


        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

// MARK: - UIViewExtension
extension UIView {
    var originX :CGFloat{
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    var originY :CGFloat{
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    var width :CGFloat{
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    var height :CGFloat{
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    var centerX :CGFloat{
        get {
            return self.center.x
        }
        set {
            self.center.x = newValue
        }
    }
    var centerY :CGFloat{
        get {
            return self.center.y
        }
        set {
            self.center.y = newValue
        }
    }
    var size :CGSize{
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    
    
    @IBInspectable var cornerRadius:CGFloat{
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    @IBInspectable var shadowRadius:CGFloat{
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    @IBInspectable var borderWidth:CGFloat{
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor:UIColor{
        get {
            return UIColor.init(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var shadowColor:UIColor{
        get {
            return UIColor.init(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable var cus_ShadowOffset:CGSize{
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    @IBInspectable var shadowOpacity:Float{
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    @IBInspectable var masksToBounds:Bool{
        get {
            return self.layer.masksToBounds
        }
        set {
            self.layer.masksToBounds = newValue
        }
    }
    
    var avatarCorner: Bool {
        get {
            return self.layer.cornerRadius > 0
        }
        set {
            self.layer.cornerRadius = self.frame.width / 2
            self.layer.masksToBounds = newValue
        }
    }
    
    /// 第一次调用setGradientColor方法,后调用此方法重新设置渐变色
    func removeSetGradientColor(startColor: UIColor, endColor: UIColor, locations: [NSNumber] = [0.5, 1.0]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = locations
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.layer.sublayers?[0] = gradientLayer
    }
    
    /// 设置背景渐变色
    func setGradientColor(startColor: UIColor, endColor: UIColor, locations: [NSNumber] = [0.5, 1.0], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint =  CGPoint(x: 1, y: 0)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.startPoint = startPoint//CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = endPoint//CGPoint(x: 1, y: 0)
        gradientLayer.locations = locations
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 切指定边的圆角
    func customCutView(_ roundingCorners: UIRectCorner, cornerRadi: CGSize) {
        let maskPath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadi)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = layer.bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    /// 绘制图形 -
    func drawGraph(path: UIBezierPath) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = layer.bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    /// 绘制图形 - 传入路径参数, 需包含起始点及终点
    func drawGraph(points: [CGPoint]) {
        guard points.count > 0 else { return }
        let path = UIBezierPath()
        for (idx, obj) in points.enumerated() {
            if idx == 0 {
                path.move(to: obj)
            } else {
                path.addLine(to: obj)
            }
        }
        drawGraph(path: path)
    }
    
}

// MARK: - UIImage
extension UIImage {
    
    /**
     *  通过指定图片最长边，获得等比例的图片size
     *
     *  image       原始图片
     *  imageLength 图片允许的最长宽度（高度）
     *
     *  return 获得等比例的size
     */
    func scaleImage(image: UIImage, imageLength: CGFloat) -> CGSize {
        
        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = image.size.width
        let height = image.size.height
        
        if (width > imageLength || height > imageLength) {
            
            if width > height {
                newWidth = imageLength;
                newHeight = newWidth * height / width;
            }
            else if height > width {
                newHeight = imageLength;
                newWidth = newHeight * width / height;
            }
            else {
                newWidth = imageLength;
                newHeight = imageLength;
            }
            
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     *  获得指定size的图片
     *
     *  image   原始图片
     *  newSize 指定的size
     *
     *  return 调整后的图片
     */
    func resizeImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 高斯模糊
    ///
    /// - Parameter blur: m高斯模糊半径
    /// - Returns: 高斯模糊后的图片
    func coreBlurImage(_ blur: CGFloat, rect: CGRect) -> UIImage? {
        
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: self)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(blur, forKey: "inputRadius")
        
        guard let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
            let outImage = context.createCGImage(result, from: rect) else { return nil }
 
        return UIImage(cgImage: outImage)
    }
    
    func resizableImage() -> UIImage {
        let w = self.size.width * 0.5
        let h = self.size.height * 0.5
        self.resizableImage(withCapInsets: UIEdgeInsets(top: w, left: h, bottom: h, right: h), resizingMode: .stretch)
        
        return self
    }
}

//MARK: -Array
extension Array {
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}

//MARK: -UILabel
extension UILabel {

}

//MARK: - UIDevice
public extension UIDevice {
    
    class var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":   return "iPhone 5"
        case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":   return "国行、日版、港行iPhone 7"
        case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
        case "iPhone9,3":  return "美版、台版iPhone 7"
        case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":   return "iPhone X"
        case "iPhone11,2":    return"iPhoneXS"
        case "iPhone11,6":    return"iPhoneXS_MAX"
        case "iPhone11,8":    return"iPhoneXR"
        case "iPhone12,1":   return "iPhone 11"
        case "iPhone12,3":   return "iPhone 11Pro"
        case "iPhone12,5":   return "iPhone 11Pro Max"
            
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":   return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
        case "iPad6,11", "iPad6,12":  return "iPad 5th generation"
        case "iPad7,1", "iPad7,2":  return "iPad Pro 12.9 2nd generation"
        case "iPad7,3", "iPad7,4":  return "iPad Pro 10.5"
        case "iPad7,5", "iPad7,6":  return "iPad 6th generation"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":  return "iPad Pro 11"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":  return "iPad Pro 12.9 3rd generation"
        case "iPad11,3", "iPad11,4":  return "iPad Air 3rd generation"
            
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":   return "Apple TV 4"
        case "i386", "x86_64":   return "Simulator"
        default:  return identifier
        }
    }
}
