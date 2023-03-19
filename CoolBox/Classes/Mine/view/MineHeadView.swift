//
//  MineHeadView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

class MineHeadView: UIView {
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nickname: UILabel!
    
    @IBOutlet weak var userTypr: UILabel!
    
    var clickBlock: (() -> Void)?
    
    class func instance() -> MineHeadView {
        return UINib(nibName: "MineHeadView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MineHeadView
    }

    override func awakeFromNib() {}
    
 
    @IBAction func scanAction(_ sender: Any) {
        clickBlock?()
    }
    
    func reloadData() {
        avatar.kf.setImage(with: URL(string: Login.currentAccount().avatarUrl), placeholder: UIImage(named: "icon_login"))
        nickname.text = Login.currentAccount().nickname
        
        userTypr.text = Login.currentAccount().type == "1" ? "个人用户" : "企业用户"
    }
    
}
