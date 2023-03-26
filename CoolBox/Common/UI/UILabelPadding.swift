//
//  UILabelPadding.swift
//  huandian
//
//  Created by Jhin on 2020/9/9.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

enum PaddingLabelStyle {
    case blue
    case red
    case green
    case gray
    case none
}

// 自定义label的内边距
public class PaddingLabel: UILabel {
    
     var style: PaddingLabelStyle = .none {
        didSet {
        font = SCFont(12)
        textInsets = UIEdgeInsets(top: 1.5, left: 4, bottom: 1.5, right: 4)
        switch style {
            case .blue:
                backgroundColor = UIColor(hexString: "#E8F3FF")
                textColor = UIColor(hexString: "#165DFF")
            case .green:
                backgroundColor = UIColor(hexString: "#E8FFEA")
                textColor = UIColor(hexString: "#00B42A")
            case .red:
                backgroundColor = UIColor(hexString: "#FFECE8")
                textColor = UIColor(hexString: "#F53F3F")
            case .gray:
                backgroundColor = UIColor(hexString: "#F2F3F5")
                textColor = UIColor(hexString: "#4E5969")
            default:
                break
            }
        }
    }
    
    public var textInsets: UIEdgeInsets = .zero

    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets),
                                  limitedToNumberOfLines: numberOfLines)
        
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}
