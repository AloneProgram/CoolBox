//
//  SPUnchckedCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class SPUnchckedCell: UITableViewCell {
    
    @IBOutlet weak var kindLable: PaddingLabel!
    
    @IBOutlet weak var kindLabelWid: NSLayoutConstraint!
       
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var info: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    var resuseBlock: (() ->Void)?
    var agreeBlock: (() ->Void)?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func refuseAction(_ sender: Any) {
        resuseBlock?()
    }
    
    @IBAction func agrreAction(_ sender: Any) {
        agreeBlock?()
    }
    
    func bindSP(_ model: SPModel) {
       
        kindLable.text = GlobalConfigManager.getValue(with: model.type, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseType)
        kindLable.style = .blue
        let kindWid = kindLable.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        kindLabelWid.constant = kindWid + 8
        
        titleLabel.text = model.reason
        info.text = "提交人:\(model.username)\n部门:\(model.department)\n报销日期:\(model.date)"
        amountLabel.text = "¥ " + model.totalFee
    }
}
