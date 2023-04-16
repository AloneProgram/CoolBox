//
//  TabBarItemView.swift
//  GYC_Mobile_App_iOS
//
//  Created by 周志杰 on 2021/11/2.
//

import UIKit

let kBadgeLength: CGFloat = 16

class TabBarItemView: ItemView {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var badgeAsRedDot = false
    var showBadge = false
        
    override var badgeValue: String? {
        didSet {
            DispatchQueue.main.async {
                // 调整Badge样式
                if self.showBadge {
                    self.badgeLabel.backgroundColor = UIColor(hexString: "#E74C39")
                    self.badgeLabel.font = UIFont(name: "Helvetica", size: 10)
                    self.badgeLabel.layer.cornerRadius = 8
                    self.badgeLabel.layer.masksToBounds = true
                    self.badgeLabel.layer.borderColor = UIColor.white.cgColor
                    self.badgeLabel.layer.borderWidth = 1
                }
                self.showBadge = true
                self.badgeLabel.isHidden = self.badgeValue == nil
                
                if !self.badgeLabel.isHidden {
                    self.badgeAsRedDot = self.badgeValue == "" // 作为红点提示, 高度会有变化
                    let width: CGFloat = (self.badgeValue ?? "").length > 2 ? 22 : 16
                    self.badgeLabel.bounds = CGRect(x: 0, y: 0, width: width, height: self.badgeHeight)
                    self.badgeLabel.text = self.badgeValue

                    self.setNeedsDisplay()
                }
            }
            
        }
    }
    
    var badgeHeight: CGFloat {
        return badgeAsRedDot ? kBadgeLength : kBadgeLength
    }
    
    public var redDotIsHidden: Bool = true {
        didSet {
             badgeLabel.isHidden = redDotIsHidden
        }
    }
    
    func badgeAttributeString(_ badge: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.headIndent = 3
        style.tailIndent = 3
        style.firstLineHeadIndent = 3
        style.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Font(10),
                                                          NSAttributedString.Key.paragraphStyle: style,
                                                        NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let res = NSAttributedString(string: badge, attributes: attributes)
        return res
    }
    
    func observerShoppingBagCount() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShopingBagCount(_:)), name: Notification.Name(rawValue: "shoppingBagCountChanged"), object: nil)
    }
    
    @objc func updateShopingBagCount(_ noti: Notification) {
        let count = noti.object as? Int ?? 0
        let isMax = count > 99
        self.badgeValue = count > 0 ? (isMax ? "99+" : "\(count)") : nil
    }
}
