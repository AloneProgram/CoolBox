//
//  ML_MemberCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/22.
//

import UIKit

class MemberCellItem: ZJExpandTreeCellItem {
    var title: String?
    var id = ""
    var userId = ""
    var type = ""
    var isSelectShenpi = false
    var status = ""
    var isBeSelectd = false
    
    var inviteBlock: (() -> Void)?
}


class ML_MemberCell: UITableViewCell, ZJCellProtocol {
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var nameLeftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var seelctWid: NSLayoutConstraint!
    @IBOutlet weak var inviteBtn: UIButton!
    
    var item: MemberCellItem!

    typealias ZJCellItemClass = MemberCellItem
    
    func cellPrepared() {
        nameLabel.text = item.title
        
        selectBtn.isHidden = !item.isSelectShenpi
        selectBtn.isSelected = item.isBeSelectd
        seelctWid.constant = selectBtn.isHidden ? 0 : 20
        inviteBtn.isHidden = item.status == "3"
        
        statusLabel.isHidden = inviteBtn.isHidden
        statusLabel.text = "未加入"
        statusLabel.style = .red
        
        leftMargin.constant = CGFloat(32 * item.level)
    }

    func cellDidAppear() {}

    func cellDidDisappear() {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func inviteAction(_ sender: Any) {
        item.inviteBlock?()
    }
    
}
