//
//  ProtocolLab.swift
//  huandian
//
//  Created by Jhin on 2020/9/9.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

class ProtocolLab: UIView {

    var normalText: String? {
        didSet {
            normalLabel.text = normalText
            let width = (normalText?.widthWithConstrainedHeight(height: 16, font: font!))! + 1
            normalLabel.snp.makeConstraints { (make) in
                make.width.equalTo(width)
            }
        }
    }
    var normalTextColor: UIColor? {
        didSet {
            normalLabel.textColor = normalTextColor
        }
    }
    var highlightText: String? {
        didSet {
            highlightButton.setTitle(highlightText, for: .normal)
            let width = (highlightText?.widthWithConstrainedHeight(height: 14, font: font!))! + 2
            highlightButton.snp.makeConstraints { (make) in
                make.width.equalTo(width)
            }
        }
    }
    var highlightTextColor: UIColor? {
        didSet {
            highlightButton.setTitleColor(highlightTextColor, for: .normal)
        }
    }
    var font: UIFont? {
        didSet {
            normalLabel.font = font
            highlightButton.titleLabel?.font = font
        }
    }
    
    var isAgree: Bool {
        return selectBtn.isSelected
    }
    
    typealias block = (Bool) -> Void
    var callBack: block?
    var agreeBlock: block?
    
    private let selectBtn = UIButton()
    private let normalLabel = UILabel()
    private let highlightButton = UIButton()
    
    convenience init() {
        self.init(frame: .zero)
        
        font = Font(12)
        
        selectBtn.isSelected = true
        selectBtn.setImage(UIImage(named: "ic_agree_nor"), for: .normal)
        selectBtn.setImage(UIImage(named: "ic_agree_sel"), for: .selected)
        selectBtn.addTarget(self, action: #selector(agreeProtocol), for: .touchUpInside)
        addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        addSubview(normalLabel)
        normalLabel.snp.makeConstraints { (make) in
            make.left.equalTo(selectBtn.snp.right).offset(5)
            make.top.bottom.equalToSuperview()
        }
        
        addSubview(highlightButton)
        highlightButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        highlightButton.snp.makeConstraints { (make) in
            make.left.equalTo(normalLabel.snp.right)
            make.right.top.bottom.equalToSuperview()
        }
        
    }
    
    @objc func click() {
        callBack?(true)
    }
    
    @objc private func agreeProtocol() {
        selectBtn.isSelected = !selectBtn.isSelected
        agreeBlock?(selectBtn.isSelected)
    }
}

