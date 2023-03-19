//
//  ItemView.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

class ItemView: UIButton {
    
    lazy var imageViewLength: CGFloat = {
        return 20
    }()
    
    convenience init(title: String?,
                     nImgName: String?,
                     sImgName: String?,
                     normalTextColor: UIColor,
                     selectedTextColor: UIColor) {
        
        self.init(type: .custom)
        
        self.imageView?.contentMode = .center
        self.setTitle(title, for: .normal)
        self.setTitleColor(normalTextColor, for: .normal)
        self.setTitleColor(selectedTextColor, for: .selected)
        
        // 正常图
        if let nImgName = nImgName {
            if nImgName.contains("http") {
                self.kf.setImage(with: URL(string: nImgName), for: .normal)
            } else {
                self.setImage(UIImage(named: nImgName), for: .normal)
            }
        }
        
        // 选中状态图
        if let sImgName = sImgName {
            if sImgName.contains("http") {
                self.kf.setImage(with: URL(string: sImgName), for: .selected)
            } else {
                self.setImage(UIImage(named: sImgName), for: .selected)
            }
        }
        
        guard let imageView = imageView else { return }
        imageView.contentMode = .scaleToFill
    }
    
    // ------------------------------ 布局 ------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageTitleVertical()
    }
    
    // 垂直布局
    private func layoutImageTitleVertical() {
        guard let imageView = imageView, let titleLabel = titleLabel else { return }
        let length = imageViewLength
        imageView.width = length
        imageView.height = length

        let contentHeight = imageView.height + titleLabel.height
        let margin = max(0, (height - contentHeight) / 2.0)

        // center image
        var imgCenter = imageView.center
        imgCenter.x = width / 2.0 - 1
        imgCenter.y = (imageView.height) / 2.0 + margin - 1
        imageView.center = imgCenter

    
        // Center text
        var newFrame = titleLabel.frame
        newFrame.origin.x = 0
        newFrame.origin.y = min(height - (titleLabel.height), (imageView.originY) + (imageView.height)) + 2
        newFrame.size.width = width

        titleLabel.frame = newFrame
        titleLabel.textAlignment = .center
    }

}

extension UILabel {
    convenience init(text: String?,
                     font: UIFont?,
                     nColor: UIColor?,
                     hlColor: UIColor? = nil
                     ) {
        self.init()
        
        self.text = text
        self.font = (font != nil) ? font : Font(14)
        self.textColor = (nColor != nil) ? nColor : EColor.darkGrayText
        self.highlightedTextColor = (hlColor != nil) ? nColor : EColor.darkGrayText
        self.numberOfLines = 0
        self.textAlignment = .left
    }
}
