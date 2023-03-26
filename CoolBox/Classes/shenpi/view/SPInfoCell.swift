//
//  SPInfoCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class SPInfoCell: UITableViewCell {
    
    @IBOutlet weak var kindLable: PaddingLabel!
    
    @IBOutlet weak var kindLabelWid: NSLayoutConstraint!
   
    @IBOutlet weak var redLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var info: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var statusLabel: PaddingLabel!
    
    @IBOutlet weak var statusLabelWid: NSLayoutConstraint!
  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindSP(_ model: SPModel, tag: Int) {
       
        kindLable.text = GlobalConfigManager.getValue(with: model.type, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseType)
        kindLable.style = .blue
        let kindWid = kindLable.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        kindLabelWid.constant = kindWid + 8
        
        titleLabel.text = model.reason
        info.text = "提交人:\(model.username)\n部门:\(model.department)\n报销日期:\(model.date)"
        amountLabel.text = "¥ " + model.totalFee
        
        switch model.status {
        case "0":
            statusLabel.text = "未审批"
            statusLabel.style = .red
        case "1":
            statusLabel.text = "审批中"
            statusLabel.style = .green
        case "3":
            statusLabel.text = "已通过"
            statusLabel.style = .gray
        case "5":
            statusLabel.text = "已拒绝"
            statusLabel.style = .red
        default:
            break
        }
        let sWid = statusLabel.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        statusLabelWid.constant = sWid + 8
        
        redLabel.isHidden = model.isRead
        
        if tag == 1 {
            redLabel.isHidden = true
        }
    }
}
