//
//  BaseHeightBottomView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

enum BaseHeightBottomType {
    //组织列表
    case companyList
    
    //加入组织
    case joinCompany
    
    //添加成员
    case addMember
    
    //选择审批人
    case selctShenpi
    
    var leftTitle: String {
        switch self {
        case .companyList, .joinCompany:
            return "加入组织"
        case .addMember, .selctShenpi:
            return "添加部门"
        }
    }
    
    var rightTitle: String {
        switch self {
        case .companyList:
            return "创建组织"
        case .addMember, .selctShenpi:
            return "添加成员"
        default:
            return ""
        }
    }
    
}

class BaseHeightBottomView: UIView {

    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var middleMargin: NSLayoutConstraint!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var rightBtnWid: NSLayoutConstraint!
    
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    var bottomType: BaseHeightBottomType = .companyList {
        didSet {
            leftBtn.setTitle(bottomType.leftTitle, for: .normal)
            rightBtn.setTitle(bottomType.rightTitle, for: .normal)
            rightBtn.isHidden = bottomType == .joinCompany
            middleMargin.constant = bottomType == .joinCompany ? 0 : 24
            rightBtnWid.constant = bottomType == .joinCompany ? 0 : kScreenWidth - 120 - 24 - 16*2
        }
    }
    
    var leftBlock: (() -> Void)?
    var rightBlock: (() -> Void)?
    
    
    class func instance() -> BaseHeightBottomView {
        return UINib(nibName: "BaseHeightBottomView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! BaseHeightBottomView
    }

    override func awakeFromNib() { }

    
    @IBAction func leftAction(_ sender: Any) {
        leftBlock?()
    }
    
    
    @IBAction func rightAction(_ sender: Any) {
        rightBlock?()
    }
}

