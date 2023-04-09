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
    case fp_unNeed  //无需报销
    
    case bx_detail  //报销单详情
    
    case sp_first  //发起人非审批人
    case sp_second  //发起人且审批人
    case sp_third  //审批人非发起人
    case sp_fourth  //审批人--已审批——审批通过
    case sp_fifth  //审批人--已审批——审批拒绝
    case sp_sixth   //发起人---已拒绝
    case sp_seventh   //发起人---已通过
}

class BottomActionView: UIView {
    
    var actionBlock: ((Int) -> Void)?
    
    var type: BottomActionType = .fp_normal
    
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
        
        var distribution: UIStackView.Distribution = .fillProportionally
        
        switch type {
        case .fp_normal:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除发票", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletFP)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "无需报销", titleColor: UIColor(hexString: "#165DFF"), selector: #selector(unbaleBX)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "创建报销单", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(createBX))
            ]
        case .fp_unNeed:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除发票", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletFP)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "创建报销单", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(createBX))
            ]
        case .fp_delete:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除发票", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletFP)),
            ]
        case .bx_detail:
            viewArray = [
                actionBtn(color: UIColor(hexString: "#F53F3F"), title: "删除报销单", titleColor: UIColor(hexString: "#F53F3F"), selector: #selector(deletBx)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "修改报销单", titleColor: UIColor(hexString: "#165DFF"), selector: #selector(editBx)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "发起审批", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(createSP))
            ]
        case .sp_first:
            distribution = .fillEqually
            viewArray = [
                actionBtn(color: UIColor(hexString: "#FF5722"), title: "撤回", titleColor: UIColor(hexString: "#FF5722"), selector: #selector(deleteSP)),
            ]
        case .sp_second:
            distribution = .fillEqually
            viewArray = [
                actionBtn(color: UIColor(hexString: "#FF5722"), title: "撤回", titleColor: UIColor(hexString: "#FF5722"), selector: #selector(deleteSP)),
                actionBtn(color: UIColor(hexString: "#FF5722"), title: "拒绝", bgColor: UIColor(hexString: "#FF5722"), titleColor: .white, selector: #selector(refuseSP)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "通过", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(passSP))
            ]
        case .sp_third:
            distribution = .fillEqually
            viewArray = [
                actionBtn(color: UIColor(hexString: "#FF5722"), title: "拒绝", bgColor: UIColor(hexString: "#FF5722"), selector: #selector(refuseSP)),
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "通过", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(passSP))
            ]
        case .sp_fourth:
            distribution = .fillEqually
            viewArray = [
                UILabel(text: "已通过", font: Font(18), nColor: UIColor(hexString: "#165DFF")),
            ]
        case .sp_fifth:
            distribution = .fillEqually
            viewArray = [
                UILabel(text: "已拒绝", font: Font(18), nColor: UIColor(hexString: "#FF5722")),
            ]
        case .sp_sixth:
            distribution = .fillEqually
            viewArray = [
                actionBtn(color: UIColor(hexString: "#165DFF"), title: "再次提交", bgColor: UIColor(hexString: "#165DFF"), selector: #selector(resendSP))
            ]
        case .sp_seventh:
            distribution = .fillEqually
            viewArray = [
                UILabel(text: "已通过", font: Font(18), nColor: UIColor(hexString: "#165DFF")),
            ]
        }
        
        
        let stackView = UIStackView(arrangedSubviews: viewArray)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = distribution
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
    
    //删除报销单
    @objc func deletBx() {
        actionBlock?(3)
    }
    
    // 修改报销单
    @objc func editBx() {
        actionBlock?(4)
    }
    
    //发起审批
    @objc func createSP() {
        actionBlock?(5)
        
    }
    
    //撤回审批
    @objc func deleteSP() {
        actionBlock?(6)
    }
    //拒绝审批
    @objc func refuseSP() {
        actionBlock?(7)
    }
    //通过审批
    @objc func passSP() {
        actionBlock?(8)
    }
    //上一个
    @objc func lastSP() {
        actionBlock?(9)
    }
    //下一个
    @objc func nextSP() {
        actionBlock?(10)
    }
    //重新发起审批
    @objc func resendSP() {
        actionBlock?(11)
    }
}
