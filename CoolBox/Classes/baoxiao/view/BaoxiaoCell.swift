//
//  BaoxiaoCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class BaoxiaoCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: PaddingLabel!
    
    @IBOutlet weak var statusLabelWid: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var kindLable: PaddingLabel!
    
    @IBOutlet weak var kindLabelWid: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindBaoxiao(_ model: BaoxiaoModel) {
        //报销状态 0未审批 1审核中 3已报销 5审核驳回
        switch model.status {
        case "0":
            statusLabel.text = "未审批"
            statusLabel.style = .red
        case "1":
            statusLabel.text = "审批中"
            statusLabel.style = .blue
        case "3":
            statusLabel.text = "已通过"
            statusLabel.style = .gray
        case "5":
            statusLabel.text = "已拒绝"
            statusLabel.style = .red
        default:
            break
        }
        
        let statusWid = statusLabel.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        statusLabelWid.constant = statusWid + 8

        titleLabel.text = model.reason
        dateLabel.text = "创建时间:" + model.date
        amountLabel.text = "¥ " + model.totalFee
        
        kindLable.text = GlobalConfigManager.getValue(with: model.type, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseType)
        kindLable.style = .blue
        let kindWid = kindLable.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        kindLabelWid.constant = kindWid + 8
    }
    
}
