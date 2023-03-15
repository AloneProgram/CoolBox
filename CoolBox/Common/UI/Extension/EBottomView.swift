//
//  EBottomView.swift
//  huandian
//
//  Created by jhin on 2021/1/8.
//  Copyright © 2021 immptor. All rights reserved.
//

import UIKit

class EBottomView: UIView {
    
    private var btnTitle = ""
    private var btnBlock: (() -> Void)?
    
    private var addButton: UIButton?
    
    init(_ title: String, action: @escaping () -> Void) {
        self.btnTitle = title
        self.btnBlock = action
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        backgroundColor = .white
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor(hexString: "#000000", alpha: 0.08).cgColor
        layer.shadowOpacity = 0.5
        
        addButton = UIButton(title: btnTitle,bgImage: R.image.bg_gradient()!)
        addButton?.setBackgroundImage(UIImage.color(EColor.disableColor), for: .disabled)
//        if let target = btnTarget {
            addButton!.addTarget(self, action: #selector(test), for: .touchUpInside)
//        }
        addSubview(addButton!)
        addButton!.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalTo(20)
            make.top.equalTo(13)
        }
    }
    
    /// 设置按钮状态
    /// - Parameter enable: true: 可点击; false: 不可点击
    func setEnable(_ enable: Bool) {
        addButton?.isEnabled = enable
    }
    
    @objc func test(){
        btnBlock?()
    }
}


class EBorderBtnBottomView: UIView {
    
    private var btnTitle = ""
    private var btnBlock: (() -> Void)?
    private var bntBorderColor = UIColor(hexString: "#24252D")
    private var bntTitleColor = UIColor(hexString: "#24252D")
    
    init(_ title: String, broderColor: UIColor = UIColor(hexString: "#24252D"), titleColor: UIColor = UIColor(hexString: "#24252D"), action: @escaping () -> Void) {
        self.btnTitle = title
        self.btnBlock = action
        self.bntBorderColor = broderColor
        self.bntTitleColor = titleColor
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        backgroundColor = .white
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor(hexString: "#000000", alpha: 0.08).cgColor
        layer.shadowOpacity = 0.5
        
        let addButton = UIButton(type: .custom)
        addButton.setTitle(btnTitle, for: .normal)
        addButton.setTitleColor(bntTitleColor, for: .normal)
        addButton.titleLabel?.font = SCMediumFont(16)
        addButton.borderColor = bntBorderColor
        addButton.borderWidth = 1
        addButton.cornerRadius = 4
        addButton.masksToBounds = true
        addButton.addTarget(self, action: #selector(test), for: .touchUpInside)
        addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalTo(20)
            make.top.equalTo(13)
        }
    }
    
    @objc func test(){
        btnBlock?()
    }
}
