//
//  EButton.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

extension UIButton {
    /// APP 大多数Button样式,黑色渐变背景色（可让UI切图），圆角4pt，默认 isEnabled
    /// titleFont：medium 15
    convenience init(title: String,
                     image: UIImage = UIImage(),
                     bgImage: UIImage = UIImage(),
                     enabled: Bool = true,
                     bgColor: UIColor = .clear,
                     font: UIFont = MediumFont(16)) {
        self.init(type: .custom)
        
        isEnabled = enabled
        setTitle(title, for: .normal)
        titleLabel?.font = font
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor(hexString: "#999999"), for: .disabled)
        setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        setImage(image, for: .normal)
        if bgColor != .clear {
            setBackgroundImage(bgColor.image, for: .normal)
        }else {
            setBackgroundImage(bgImage, for: .normal)
        }
        setBackgroundImage(bgColor.withAlphaComponent(0.7).image, for: .highlighted)
        setBackgroundImage(EColor.disableColor.image, for: .disabled)
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    /// APP  border 样式，白底，橘色边框，圆角4pt
    /// titleFont：Regular 15
    convenience init(borderTitle: String,
                            font: UIFont = MediumFont(15),
                            titleColor: UIColor = UIColor(redInt: 123, greenInt: 126, blueInt: 144)) {
        self.init(type: .custom)
        
        setTitle(borderTitle, for: .normal)
        titleLabel?.font = font
        setTitleColor(titleColor, for: .normal)
        setTitleColor(titleColor.withAlphaComponent(0.7), for: .highlighted)
        
        layer.borderWidth = 1
        layer.borderColor = EColor.lineColor.cgColor
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    
    /// APP border 样式，自定义背景色、边框、圆角
    /// titleFont：Regular 15
    convenience init(borderTitle: String,
                     bgColor: UIColor = .clear,
                     borderColor: UIColor = .white,
                     font: UIFont = Font(14),
                     radius: CGFloat = 2,
                     titleColor: UIColor = .white) {
        self.init(type: .custom)
        
        backgroundColor = bgColor
        setTitle(borderTitle, for: .normal)
        titleLabel?.font = font
        setTitleColor(titleColor, for: .normal)
        setTitleColor(titleColor.withAlphaComponent(0.7), for: .highlighted)
        
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    
}

//class RightImageButton: UIButton {
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let space: CGFloat = 8
//        let selfW = self.bounds.width
//        let selfH = self.bounds.height
//        
//        if let imageV = self.imageView {
//            var imageF = imageV.frame
//            let imageW: CGFloat = imageF.width
//            if let label = self.titleLabel {
//                label.center = CGPoint(x: selfW / 2.0 - imageW / 2.0 - space, y: selfH / 2.0)
//                imageF.origin.x = label.frame.maxX + space
//                imageV.frame = imageF
//                imageV.center = CGPoint(x: imageV.center.x, y: selfH / 2.0)
//            }
//        }
//    }
//}

class TopImageButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selfW = self.bounds.width
        let selfH = self.bounds.height
        
        if let imageV = self.imageView {
            var imageF = imageV.frame
            imageF.origin.x = (selfW - imageF.size.width) / 2.0
            imageF.origin.y = 0
            imageV.frame = imageF
        }
        
        if let label = self.titleLabel {
            var labelF = label.frame
            labelF.origin.x = (selfW - labelF.size.width) / 2.0
            labelF.origin.y = selfH - labelF.size.height
            label.frame = labelF
        }
    }
}

class LeftImageButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let space: CGFloat = 4
        let selfW = self.bounds.width
        let selfH = self.bounds.height
        
        if let lable = self.titleLabel {
            var lableF = lable.frame
            let lableW: CGFloat = lableF.width
            if let imageV = self.imageView {
                imageV.center = CGPoint(x: selfW / 2.0 - lableW / 2.0 - space, y: selfH / 2.0)
                lableF.origin.x = imageV.frame.maxX + space
                lable.frame = lableF
                lable.center = CGPoint(x: lable.center.x, y: selfH / 2.0)
            }
        }
    }
}
