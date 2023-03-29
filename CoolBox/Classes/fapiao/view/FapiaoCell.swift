//
//  FapiaoCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

class FapiaoCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: PaddingLabel!
    
    @IBOutlet weak var titleLeftmargin: NSLayoutConstraint!
    @IBOutlet weak var statusLabelWid: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var rightArrow: UIImageView!
    
    @IBOutlet weak var kindLable: PaddingLabel!
    
    @IBOutlet weak var kindLabelWid: NSLayoutConstraint!
    
    @IBOutlet weak var buyerLabel: PaddingLabel!
    
    @IBOutlet weak var buyerLabelWid: NSLayoutConstraint!
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var tipsIcon: UIImageView!
    
    @IBOutlet weak var tipsIconHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tipsTopMargin: NSLayoutConstraint!
    
    var clickSelectedBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAction(_ sender: Any) {
        clickSelectedBlock?()
    }
    
    func bindFapiao(_ fapiao: FaPiaoModel) {
        //报销状态 0未报销 1报销中 3已报销 5无需报销
        switch fapiao.status {
        case "0":
            if fapiao.isSync == "0" {
                statusLabel.text = "未同步"
            }else if fapiao.isSync == "2" {
                statusLabel.text = "同步失败"
            }else if fapiao.isDataComplete == "0" {
                statusLabel.text = "信息不完整"
            } else {
                statusLabel.text = "未报销"
            }
           
            statusLabel.style = .red
        case "1":
            statusLabel.text = "报销中"
            statusLabel.style = .gray
        case "2":
            statusLabel.text = "已报销"
            statusLabel.style = .blue
        case "3":
            statusLabel.text = "无需报销"
            statusLabel.style = .gray
        default:
            statusLabel.text = ""
            break
        }
        let statusWid = statusLabel.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        if statusWid > 0 {
            statusLabelWid.constant = statusWid + 8
        }else {
            statusLabelWid.constant = 0
            titleLeftmargin.constant = 0
        }
        

        titleLabel.text = fapiao.title
        dateLabel.text = "消费时间:" + fapiao.productionDate
        amountLabel.text = "¥ " + fapiao.fee
        
        selectBtn.isHidden = fapiao.invalidTitle.length > 0
        rightArrow.isHidden = !(fapiao.isDataComplete == "0" && fapiao.isSync == "1")
        if !rightArrow.isHidden {
            selectBtn.isHidden = true
        }
        
        if fapiao.isSelectListPage {
            rightArrow.isHidden = true
        }
        
        if statusWid == 0 {
            selectBtn.isHidden = true
        }
        
        kindLable.text = GlobalConfigManager.getValue(with: fapiao.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
        kindLable.style = .blue
        let kindWid = kindLable.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        kindLabelWid.constant = kindWid + 8

        buyerLabel.isHidden = fapiao.buyerName.length == 0
        buyerLabel.text = fapiao.buyerName
        buyerLabel.style = .gray
        let buyerWid =  buyerLabel.text?.widthWithConstrainedHeight(height: 20, font: SCFont(12)) ?? 0
        buyerLabelWid.constant = buyerWid + 8

        tipsLabel.text = fapiao.invalidTitle
        tipsLabel.isHidden = fapiao.invalidTitle.length == 0
        tipsIcon.isHidden = tipsLabel.isHidden
        
        tipsIconHeight.constant = tipsIcon.isHidden ? 0 : 10
        tipsTopMargin.constant = tipsIcon.isHidden ? 0 : 10
        
        selectBtn.isSelected = fapiao.isSelected
    }
}
