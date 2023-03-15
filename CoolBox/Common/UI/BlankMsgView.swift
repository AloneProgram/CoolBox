//
//  BlankMsgView.swift
//  huandian
//
//  Created by Jhin on 2020/9/27.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import UIKit

/// 空白页提示图
protocol BlankMsgViewType {
    
    /// 没有消息时, 纯文本的空白提示图
    static func blankMsgView(_ hint: String) -> UIView
    
    /// 没有消息时, 带图片的空白提示图
    static func blankMsgView(_ hint: String, imageStr: String, btnTitle: String?, actionCallback block: ((UIButton) -> Void)?) -> UIView
    
}

extension UIView {
    
    /// 没有消息时, 纯文本的空白提示图
//    static func blankMsgView(_ hint: String) -> UIView {
//
//        let blankView = UIView()
//        blankView.backgroundColor = .white
//        blankView.isHidden = true
//
//        let textLabel = UILabel()
//        textLabel.textAlignment = .center
//        textLabel.textColor = UIColor.lightText
//        textLabel.frame = blankView.bounds
//        textLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
//        textLabel.text = hint
//        blankView.addSubview(textLabel)
//        
//        return blankView
//
//    }
    
    static func blankMsgView(_ hint: String, imageStr: String = "ic_noData", btnTitle: String = "", actionCallback block: ((UIButton)-> Void)? = nil) -> UIView {
        
        let blankView = UIView()
        blankView.backgroundColor = .clear
//        blankView.isHidden = true
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = Font(14)
        textLabel.textColor = UIColor(rgb: 153)
        textLabel.text = hint
        textLabel.textAlignment = .center
        blankView.addSubview(textLabel)
        
        let image = UIImageView()
        image.image = UIImage(named: imageStr)
        image.contentMode = .center
        blankView.addSubview(image)
        
        image.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.width.equalTo(kScreenWidth - 20)
            make.centerX.equalToSuperview()
            make.top.equalTo(image.snp.bottom).offset(20)
        }
        
        guard btnTitle.count > 0 else { return blankView}
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .black
        btn.titleLabel?.font = Font(13)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(btnTitle, for: .normal)
        blankView.addSubview(btn)
        
//        image.snp.updateConstraints { (make) in
//            make.top.equalTo(188)
//        }
        
        btn.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(34)
            make.top.equalTo(textLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        btn.layoutIfNeeded()
        btn.cornerRadius = 4
        
        guard let btnBlock = block else { return blankView}
        btnBlock(btn)
        
        return blankView
    }
    
}
