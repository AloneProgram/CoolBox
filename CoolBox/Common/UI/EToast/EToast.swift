//
//  EToast.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import MBProgressHUD

/// 显示在window上的 HUD
struct EHUD {
    public static func show(_ tip: String? = nil) {
        currentWindow()?.beginLoading(tip: tip)
    }

    public static func dismiss() {
        currentWindow()?.endLoading()
    }

    private static func currentWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
}

public let kDefaultTimeInterval: TimeInterval = 1.5

struct EToast {
    
    private static var miniSize = CGSize(width: 100, height: 70)
    private static var margin: CGFloat = 15
        
    private static var successImageView = UIImageView(image: UIImage(named: "success"))
    private static var errorImageView = UIImageView(image: UIImage(named: "error"))
    private static var infoImageView = UIImageView(image: UIImage(named: "info"))
    
    public static func setSuccessImage(_ image: UIImage?) {
        let imageView = UIImageView(image: image)
        EToast.successImageView = imageView
    }
    
    public static func setErrorImage(_ image: UIImage?) {
        let imageView = UIImageView(image: image)
        EToast.errorImageView = imageView
    }
    
    public static func setInfoImage(_ image: UIImage?) {
        let imageView = UIImageView(image: image)
        EToast.infoImageView = imageView
    }
    
    public static func setMiniSize(_ size: CGSize) {
        EToast.miniSize = size
    }
    public static func setMargin(_ margin: CGFloat) {
        EToast.margin = margin
    }
    
    // -----成功---------
    public static func showSuccess() {
        EToast.showSuccess(nil)
    }
    public static func showSuccess(_ tip: String?) {
        EToast.showHud(EToast.successImageView, tip: tip, delay: kDefaultTimeInterval, handle: nil)
    }
    public static func showSuccess(_ tip: String? = "", delayDismiss: TimeInterval, completion: (() -> Void)? = nil) {
        EToast.showHud(EToast.successImageView, tip: tip, delay: delayDismiss, handle: completion)
    }
    
    //-------失败-----
    public static func showFailed() {
        EToast.showFailed(nil)
    }
    public static func showFailed(_ tip: String?) {
        EToast.showHud(EToast.errorImageView, tip: tip, delay: kDefaultTimeInterval, handle: nil)
    }
    public func showFailed(tip: String = "", delayDismiss: TimeInterval, completion:(() -> Void)? = nil) {
        EToast.showHud(EToast.errorImageView, tip: tip, delay: delayDismiss, handle: completion)
    }
    
    // ---info-----
    public static func showInfo(_ tip: String?) {
        EToast.showHud(EToast.infoImageView, tip: tip, delay: kDefaultTimeInterval, handle: nil)
    }
    public static func showInfo(tip: String = "", delayDismiss: TimeInterval = kDefaultTimeInterval, completion:(() -> Void)? = nil) {
        EToast.showHud(EToast.infoImageView, tip: tip, delay: delayDismiss, handle: completion)
    }
    
    // -----自定义图片+文字-----
    public static func showCustom(_ tip: String = "", imageName: String, delayDismiss: TimeInterval = kDefaultTimeInterval, completion:(() -> Void)? = nil) {
        EToast.showHud(UIImageView(image: UIImage(named: imageName)), tip: tip, delay: delayDismiss, handle: completion)
    }
}

// MARK: - toast only text
extension EToast {
    public static func showToast(tip: String?) {
        self.showHudTip(tip, offsetY: 0)
    }
    
    public static func showTopToast(tip: String?) {
        self.showHudTip(tip, offsetY: -MBProgressMaxOffset)
    }
    
    public static func showBottomToast(tip: String?) {
        self.showHudTip(tip, offsetY: MBProgressMaxOffset)
    }
}

private extension EToast {

    
    static func showHud(_ imageView: UIImageView?, tip: String?, delay: TimeInterval, handle: (() -> Void)? = nil ) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        hud.mode = .customView
        hud.customView = imageView
        hud.removeFromSuperViewOnHide = true
        hud.minSize = EToast.miniSize
        hud.margin = EToast.margin
        hud.label.font = UIFont.systemFont(ofSize: 14)

        guard let tip = tip else {
            hud.hide(animated: true, afterDelay: delay)
            return
        }
        
        let tips: [String] = tip.components(separatedBy: "\n")
        if tips.count > 1 {
            hud.label.text = tips.first
            let string = tip.components(separatedBy: "\(tips.first ?? "")\n").last
            hud.detailsLabel.text = string
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        }else {
            hud.label.numberOfLines = 0
            hud.label.text = tip
        }
        
        let afterDelay = max(Double(tip.count) / 10.0, 1)
        
        hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        hud.bezelView.style = .solidColor
        hud.bezelView.layer.cornerRadius = 2
        hud.contentColor = .white
        hud.tintColor = .white
        hud.hide(animated: true, afterDelay: afterDelay)
        
        if let handle = handle {
            let delaySeconds = delay + afterDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds, execute: handle)
        }
    }
    
    /**
     offsetY 0:中间; MBProgressMaxOffset:底部; -MBProgressMaxOffset:顶部
     */
    static func showHudTip(_ tipString: String?, offsetY: CGFloat) {
        var afterDelay = 0.0
        afterDelay += Double(tipString?.count ?? 0) / 10.0
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        let superView = UIView(frame: keyWindow.bounds)
        let subView = UIView(frame: CGRect(x: 0, y: 40, width: superView.bounds.width, height: superView.bounds.height - 70))
        superView.backgroundColor = .clear
        subView.backgroundColor = .clear
        keyWindow.addSubview(superView)
        superView.addSubview(subView)
        
        let hud = MBProgressHUD.showAdded(to: subView, animated: true)
        hud.mode = .text
        hud.margin = 15
        hud.label.font = UIFont.systemFont(ofSize: 14)
        
        guard let tipString = tipString else {
            hud.hide(animated: true, afterDelay: afterDelay)
            return
        }
        
        let tips: [String] = tipString.components(separatedBy: "\n")
        if tips.count > 1 {
            hud.label.text = tips.first
            
            let string = tipString.components(separatedBy: "\(tips.first ?? "")\n").last
            hud.detailsLabel.text = string
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        }else {
            hud.label.text = tipString
            hud.label.numberOfLines = 0
        }
        
        hud.removeFromSuperViewOnHide = true
        hud.offset = CGPoint(x: 0, y: offsetY)
        
        hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        hud.bezelView.style = .solidColor
        hud.bezelView.layer.cornerRadius = 2
        hud.contentColor = .white
        hud.hide(animated: true, afterDelay: max(afterDelay, 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + max(afterDelay, 1)) {
            subView.removeFromSuperview()
            superView.removeFromSuperview()
        }
    }
}

fileprivate extension UIView {
    // MARK: - RuntimeKey,动态绑属性
     struct RuntimeHUDKey {
        static let kProgressHUD = UnsafeRawPointer.init(bitPattern: "kProgressHUD".hashValue)
    }
    
    // MARK: - HUD
    var HUD: MBProgressHUD? {
        get {
            return  objc_getAssociatedObject(self, UIView.RuntimeHUDKey.kProgressHUD!) as? MBProgressHUD
        }
        set {
            objc_setAssociatedObject(self, UIView.RuntimeHUDKey.kProgressHUD!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 创建hud
    func createHUD() {
        if self.HUD != nil {
            return
        }
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.margin = 15
        hud.bezelView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        hud.bezelView.style = .solidColor
        hud.bezelView.layer.cornerRadius = 2
        hud.contentColor = .white
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 13)
        self.HUD = hud
    }
 
    func beginLoading(tip: String?) {
        createHUD()
        self.endEditing(true)
        self.HUD?.mode = .indeterminate
        self.HUD?.backgroundView.isUserInteractionEnabled = false
        if tip != nil {
            self.HUD?.detailsLabel.text = tip
        }
    }
    
    func endLoading() {
        if self.HUD != nil {
            self.HUD?.hide(animated: true)
            self.HUD = nil
        }
    }
}

