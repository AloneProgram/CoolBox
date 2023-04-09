//
//  BXFapiaoCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/6.
//

import UIKit

class BXFapiaoCell: UITableViewCell {
    
    
    @IBOutlet weak var companyNameLabel: UILabel!

    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var fellLabel: UILabel!
    
    @IBOutlet weak var feeTypeLabel: UILabel!
    
    @IBOutlet weak var rightArrow: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindInvoice(_ invoiceList: InvoiceData, showRight: Bool = true) {
        guard let invoice = invoiceList.list.first else { return }
        companyNameLabel.text = invoice.sellerName
        dateLabel.text = invoice.time
        
        fellLabel.text = "¥" + invoice.fee
        feeTypeLabel.text = GlobalConfigManager.getValue(with: invoice.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType ?? [:])
        
        rightArrow.isHidden = !showRight
        
        topMargin.constant = 16
        topLabel.isHidden = true
    }
    
    func bindInvoiceData(_ invoice: FapiaoDetailModel, autoSize: Bool = true) {
        companyNameLabel.numberOfLines = autoSize ? 0 : 1
        companyNameLabel.text = invoice.sellerName
        dateLabel.text = invoice.time
        
        topLabel.isHidden = true
        fellLabel.text = "¥" + invoice.fee
        feeTypeLabel.text = GlobalConfigManager.getValue(with: invoice.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType ?? [:])
        
        rightArrow.isHidden = false
        topMargin.constant = 16
        
        
    }
    
    func bindTravel(_ travel: TravleData, showRightArrow: Bool = true) {
        topMargin.constant = 34
        topLabel.isHidden = false
        
        rightArrow.isHidden = !showRightArrow
        
        if travel.startTime.length > 0, travel.endTime.length > 0 {
            topLabel.textColor = UIColor(hexString: "#86909C")
            topLabel.text = travel.startTime + "-" + travel.endTime
        }else {
            topLabel.textColor = UIColor(hexString: "#FF5722")
            topLabel.text = "请补充行程时间"
        }
        
        companyNameLabel.text = travel.title
        
        
        dateLabel.text = "出差补贴\(travel.subsidyDay)天¥\(travel.subsidyFee)元"
        
        fellLabel.isHidden = true
        feeTypeLabel.text = GlobalConfigManager.getValue(with: travel.vehicleType, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseVehicleType ?? [:])
   
    }
}
