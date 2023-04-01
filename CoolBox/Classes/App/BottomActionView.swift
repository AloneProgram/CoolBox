//
//  FPBottomActionView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/29.
//

import UIKit

enum BottomActionType {
    case fp_normal
    case fp_delete
}

class BottomActionView: UIView {
    
    var actionBlock: ((Int) -> Void)?
    
    var type: BottomActionType = .fp_normal {
        didSet {
        }
    }
    
    init( type: BottomActionType = .fp_normal, frame: CGRect) {
        super.init(frame: frame)
        self.type = type
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        var viewArray: [UIView] = []
        
        switch type {
        case .fp_normal:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除发票", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletFP)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "无需报销", titleColor: UIColor(hexString: "#165DFF"), selector: #selector(unbaleBX)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "创建报销单", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(deletFP))
            ]
        case .fp_delete:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除发票", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletFP)),
            ]
        }
        
        
        let stackView = UIStackView(arrangedSubviews: viewArray)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 32
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }
    
    func actionBtn(color: UIColor = .white, title: String, bgColor: UIColor = .clear, titleColor: UIColor = .white, selector: Selector) -> UIButton {
        let btn = UIButton(borderTitle: title, bgColor: bgColor, borderColor: color, titleColor: titleColor)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        let wid = title.widthWithConstrainedHeight(height: 32, font: Font(14)) + 32
        btn.frame = CGRect(origin: .zero, size: CGSize(width: wid, height: 32))
        return btn
    }
    
    
    @objc func deletFP() {
        actionBlock?(0)
    }
    
    //无需报销
    @objc func unbaleBX() {
        actionBlock?(1)
    }
    
    //创建报销单
    @objc func createBX() {
        actionBlock?(2)
        
    }
}