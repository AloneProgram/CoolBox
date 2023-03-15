//
//  EToast.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
@_exported import WProgressHUD

/// 显示在window上的 HUD
struct EHUD {
    static func show(_ tip: String? = nil) {
        currentWindow()?.beginLoading(withTip: tip)
    }
     
    static func dismiss() {
        currentWindow()?.endLoading()
    }
    
    private static func currentWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
}

struct EToast {
    
    // MARK: - status
    
    static func showSuccess() {
        WToast.showSuccess()
    }
    
    static func showSuccess(_ tip: String?) {
        WToast.showSuccess(withTip: tip)
    }
    
    static func showSuccess(_ tip: String?, delayDismiss delay: TimeInterval, completion: (() -> Void)? = nil) {
        WToast.showSuccess(withTip: tip, delayDismiss: delay, completion: completion)
    }
    
    static func showFailed() {
        WToast.showFailed()
    }
    
    static func showFailed(_ tip: String?) {
        WToast.showFailed(withTip: tip)
    }
    
    static func showFailed(_ tip: String?, delayDismiss delay: TimeInterval, completion: (() -> Void)? = nil) {
        WToast.showFailed(withTip: tip, delayDismiss: delay, completion: completion)
    }
    
    static func showInfo(_ tip: String?) {
        WToast.showInfo(withTip: tip)
    }
    
    static func showInfo(_ tip: String?, delayDismiss delay: TimeInterval, completion: (() -> Void)? = nil) {
        WToast.showInfo(withTip: tip, delayDismiss: delay, completion: completion)
    }
    
    // MARK: - toast only text
    
    static func showToast(_ tip: String?) {
        WToast.show(tip)
    }
    
    static func showTopToast(_ tip: String?) {
        WToast.showTopToast(tip)
    }
    
    static func showBottomToast(_ tip: String?) {
        WToast.showBottomToast(tip)
    }
    
    // MARK: - Error Tip
    
    static func tip(fromError error: Error?) -> String? {
        return WToast.tip(fromError: error)
    }
    
    static func showError(_ error: Error?) {
        WToast.showError(error)
    }
    
    static func showHudTip(_ tipString: String?) {
        WToast.showHudTip(tipString)
    }
}
