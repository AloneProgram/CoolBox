//
//  PermissionTool.swift
//  LiveDemo
//
//  Created by winter on 2020/3/4.
//  Copyright © 2020 yeting. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

struct PermissionTool {

    /// UIAlertController == nil 说明可以继续走流程
    /// 不为空，则需要调用者 present
    typealias PermissionResult = (UIAlertController?) -> Void
    
    /// 相机和麦克风
    public static func checkCameraAndMicrophone(_ completion: PermissionResult? = nil ) {
        checkCamera { (alert) in
            guard let alert = alert else {
                checkMicrophone(completion)
                return
            }
            completion?(alert)
        }
    }
    
    /// 相机
    public static func  checkCamera(_ completion: PermissionResult? = nil ) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized { completion?(nil) }
        else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { DispatchQueue.main.async {  completion?(nil) } }
                else {
                    let alert = alertForSystemSeeting(title: "相机")
                    DispatchQueue.main.async {  completion?(alert) }
                }
            }
        }
        else {
            // authStatus == .denied || authStatus == .restricted
            let alert = alertForSystemSeeting(title: "相机")
            DispatchQueue.main.async {  completion?(alert) }
        }
    }
    
    /// 麦克风
    public static func checkMicrophone(_ completion: PermissionResult? = nil) {
        AVAudioSession.sharedInstance().requestRecordPermission { (isOpen) in
            DispatchQueue.main.async {
                if isOpen { completion?(nil) }
                else {
                    let alert = alertForSystemSeeting(title: "麦克风")
                    completion?(alert)
                }
            }
        }
    }
    
    /// 推送
    public static func checkNotification(_ completion: PermissionResult? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (setting) in
            let author = setting.authorizationStatus == .authorized
            DispatchQueue.main.async {
                if author { completion?(nil) }
                else {
                    let alert = alertForSystemSeeting(title: "推送通知")
                    completion?(alert)
                }
            }
        })
    }
    
    private static func alertForSystemSeeting(title: String) -> UIAlertController {
        let msg = "需要开启\(title)权限,请到设置->app->\(title)中, 打开\(title)权限"
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        let action = UIAlertAction(title: "去开启", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alert.addAction(cancleAction)
        alert.addAction(action)
        return alert
    }
    
    /// 检测是否开启定位
    public static func checkLocation(_ completion: PermissionResult? = nil) {
        if !LocationManager.shared.locationIsEnable {
            let alert = alertForSystemSeeting(title: "位置")
            completion?(alert)
        }else {
            completion?(nil)
        }
    }
}
